extends Node2D

var lastSelected = -1

var selectedDifficulty = 2
var selectedSpeed = 1

var scoreSelect = 0
var curScore = 0

var songData

var character1
var character2

var loadedJsons = {}
var loadedSongs = {}

var simpleFreeplay = true

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
		
	if ($CanvasLayer/ChoiceMenu.selected != lastSelected || move != 0):
		song_selected($CanvasLayer/ChoiceMenu.selected)
		
	lastSelected = $CanvasLayer/ChoiceMenu.selected
	
	curScore = lerp(curScore, scoreSelect, 10 * _delta)
	
	var displayScore = str("%08d" % round(curScore))
	$CanvasLayer/SettingsBox/Score.text = displayScore
	$CanvasLayer/SettingsBox/Label.text = "< " + Main.difficultys[selectedDifficulty] + " >\n" + str(selectedSpeed) + "x"
	var songsMenu = $CanvasLayer/ChoiceMenu
	$CanvasLayer/InfoBox2/Label.text = str(songsMenu.selected+1) + "/" + str(len(songsMenu.options)) + " SONGS"

func get_songs():
	var songsMenu = $CanvasLayer/ChoiceMenu
	songsMenu.optionOffset.y = 120
	songsMenu.options = []
	songsMenu.optionIcons = []
	
	get_freeplay_songs("res://Assets/Songs/")
	
	var dir = Directory.new()
	if (dir.dir_exists(Mods.songsDir)):
		get_freeplay_songs(Mods.songsDir)
	
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
	
	if (loadedSongs.has(songName)):
		Conductor.play_song(loadedSongs[songName], songData["bpm"])

	scoreSelect = Conductor.load_score(songName, selectedDifficulty)
	
	if (!simpleFreeplay):
		var player1 = "test"
		var player2 = "test"
		
		if (songData.has("player1") && Main.CHARACTERS.has(songData["player1"])):
			player1 = songData["player1"]
		if (songData.has("player2") && Main.CHARACTERS.has(songData["player2"])):
			player2 = songData["player2"]
		
		if (character1 != null):
			character1.queue_free()
		
		character1 = Main.create_character(player1)
		character1.setup_character()
		$CanvasLayer/Icons/Player.texture = character1.iconSheet
		
		if (character2 != null):
			character2.queue_free()
		
		character2 = Main.create_character(player2)
		character2.setup_character()
		$CanvasLayer/Icons/Enemy.texture = character2.iconSheet
		
		setup_song_info()

func song_chosen(option):
	var songName = $CanvasLayer/ChoiceMenu.options[option]
	var difficulty = Main.difficultys[selectedDifficulty].to_lower()
	
	Main.change_playstate(songName, difficulty, selectedSpeed)

func get_freeplay_songs(directory):
	var songsMenu = $CanvasLayer/ChoiceMenu
	
	var dir = Directory.new()
	dir.open(directory)
	
	dir.list_dir_begin(true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			loadedJsons[file] = Conductor.load_song_json(file)
			
			var songData = loadedJsons[file]
			
			if (songData == null):
				continue
			
			songsMenu.options.append(file)
			
			var player2 = "test"
			if (songData.has("player2") && Main.CHARACTERS.has(songData["player2"])):
				player2 = songData["player2"]
			
			if (character2 != null):
				character2.queue_free()

			character2 = Main.create_character(player2)
			character2.setup_character()
			
			var textureIcon = character2.iconSheet
			songsMenu.optionIcons.append(character2.iconSheet)
			
			if (Settings.freeplaySongPreview):
				var newDir = directory + "/" + file + "/Inst.ogg"
				loadedSongs[file] = Mods.mod_ogg(newDir)
