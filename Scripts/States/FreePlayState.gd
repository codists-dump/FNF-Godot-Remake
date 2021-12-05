extends Node2D

var lastSelected = -1

var selectedDifficulty = 2
var selectedSpeed = 1

var songData

var character1
var character2

var loadedJsons = {}
var loadedSongs = {}

func _ready():
	get_songs()
	
	var songsMenu = $CanvasLayer/ChoiceMenu
	songsMenu.optionOffset.y = 120
	songsMenu.connect("option_selected", self, "song_chosen")
	
	song_selected(0)

func _process(_delta):
	if (Input.is_action_just_pressed("cancel")):
		$CancelStream.play()
		Main.change_scene(Main.MAIN_MENU)
		
	var move = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
	if (Input.is_key_pressed(KEY_SHIFT)):
		selectedSpeed += move * 0.1
	else:
		selectedDifficulty += move
		
	selectedDifficulty = clamp(selectedDifficulty, 0, Main.difficultys.size()-1)
		
	if ($CanvasLayer/ChoiceMenu.selected != lastSelected):
		song_selected($CanvasLayer/ChoiceMenu.selected)
		
	lastSelected = $CanvasLayer/ChoiceMenu.selected
	
	$CanvasLayer/SettingsBox/Label.text = "< " + Main.difficultys[selectedDifficulty] + " >\n" + str(selectedSpeed) + "x"

func get_songs():
	var songsMenu = $CanvasLayer/ChoiceMenu
	songsMenu.optionOffset.y = 120
	songsMenu.options = []
	
	var dir = Directory.new()
	dir.open("res://Assets/Songs/")
	
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			songsMenu.options.append(file)
			loadedJsons[file] = Conductor.load_song_json(file)
			loadedSongs[file] = load("res://Assets/Songs/" + file + "/Inst.ogg")
			
	songsMenu.options.sort()
	
func setup_song_info():
	var infoLabel = $CanvasLayer/InfoBox/Label
	
	var infoString = ""
	if (songData.has("song")):
		infoString += str(songData["song"]) + "\n"
		
	infoString += "\n"	
		
	if (songData.has("bpm")):
		infoString += "BPM: " + str(songData["bpm"]) + "\n"
	if (songData.has("speed")):
		infoString += "SPD: " + str(songData["speed"]) + "\n"
	
	infoString += "\n"	
	
	if (songData.has("stage")):
		infoString += "STG: " + str(songData["stage"]) + "\n"
	if (songData.has("player1")):
		infoString += "PLR: " + str(songData["player1"]) + "\n"
	if (songData.has("player2")):
		infoString += "ENMY: " + str(songData["player2"]) + "\n"
		
	infoString += "\n"	
		
	if (songData.has("type")):
		infoString += "TYPE: " + str(songData["type"]) + "\n"
		
	infoLabel.text = infoString

func song_selected(option):
	var songName = $CanvasLayer/ChoiceMenu.options[option]
	songData = loadedJsons[songName]
	Conductor.play_song(loadedSongs[songName], songData["bpm"])
	
	var player1 = "test"
	var player2 = "test"
	
	if (songData.has("player1") && Main.CHARACTERS.has(songData["player1"])):
		player1 = songData["player1"]
	if (songData.has("player2") && Main.CHARACTERS.has(songData["player2"])):
		player2 = songData["player2"]
	
	if (character1 != null):
		character1.queue_free()
	character1 = Main.CHARACTERS[player1].instance()
	$CanvasLayer/Icons/Player.texture = character1.iconSheet
	
	if (character2 != null):
		character2.queue_free()
	character2 = Main.CHARACTERS[player2].instance()
	$CanvasLayer/Icons/Enemy.texture = character2.iconSheet
	
	setup_song_info()

func song_chosen(option):
	var songName = $CanvasLayer/ChoiceMenu.options[option]
	var difficulty = Main.difficultys[selectedDifficulty].to_lower()
	
	Main.change_playstate(songName, difficulty, selectedSpeed)
