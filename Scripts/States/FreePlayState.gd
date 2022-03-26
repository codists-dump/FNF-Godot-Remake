extends Node2D

onready var choiceMenu = $CanvasLayer/ChoiceMenu

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

var infoMode = false
var switchedMode = false

func _ready():
	get_songs()
	
	choiceMenu.optionOffset.y = 120
	choiceMenu.connect("option_selected", self, "song_chosen")
	
	song_selected(0)

func _process(_delta):
	if (Input.is_action_just_pressed("cancel")):
		$CancelStream.play()
		Main.change_scene(Main.MAIN_MENU)
		
	var move = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
	if (Input.is_key_pressed(KEY_SHIFT)):
		selectedSpeed += move * 0.1
		selectedSpeed = clamp(selectedSpeed, 0.1, 2)
	else:
		selectedDifficulty += move
		
	if (Input.is_key_pressed(KEY_TAB)):
		if (switchedMode):
			return
		
		infoMode = !infoMode
		
		if (infoMode):
			setup_song_info()
		
		switchedMode = true
	else:
		switchedMode = false
		
	selectedDifficulty = clamp(selectedDifficulty, 0, Main.difficultys.size()-1)
		
	if (choiceMenu.selected != lastSelected || move != 0):
		song_selected(choiceMenu.selected)
		
	lastSelected = choiceMenu.selected
	
	curScore = lerp(curScore, scoreSelect, 10 * _delta)
	
	var displayScore = str("%08d" % round(curScore))
	$CanvasLayer/SettingsBox/Score.text = "HIGH SCORE\n" + displayScore
	$CanvasLayer/SettingsBox/Label.text = "< " + Main.difficultys[selectedDifficulty] + " >\n" + str(selectedSpeed) + "x"
	$CanvasLayer/InfoBox2/Label.text = str(choiceMenu.selected+1) + "/" + str(len(choiceMenu.options)) + " SONGS"

	$CanvasLayer/InfoBox.visible = infoMode

	choiceMenu.infoMode = infoMode

func get_songs():
	choiceMenu.optionOffset.y = 120
	choiceMenu.options = []
	choiceMenu.optionIcons = []
	
	get_freeplay_songs("res://Assets/Songs/")
	
	var dir = Directory.new()
	if (dir.dir_exists(Mods.songsDir)):
		get_freeplay_songs(Mods.songsDir)
	
func setup_song_info():
	var infoLabel = $CanvasLayer/InfoBox/JsonDetails/Label
	
	# icons
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
	$CanvasLayer/InfoBox/Icons/Player.texture = character1.iconSheet
	
	if (character2 != null):
		character2.queue_free()
	
	character2 = Main.create_character(player2)
	character2.setup_character()
	$CanvasLayer/InfoBox/Icons/Enemy.texture = character2.iconSheet
	
	# text
	var infoString = ""
	if (songData.has("song")):
		infoString += str(songData["song"]) + "\n"
		
	infoString += "\n"	
		
	if (songData.has("bpm")):
		if (selectedSpeed == 1):
			infoString += "BPM: " + str(songData["bpm"]) + "\n"
		else:
			infoString += "BPM: " + str(songData["bpm"] * selectedSpeed) + " (" + str(songData["bpm"]) + ")" + "\n"
	if (songData.has("speed")):
		infoString += "SPD: " + str(songData["speed"]) + "\n"
	if (songData.has("notes")):
		var noteCount = 0
		for section in songData["notes"]:
			noteCount += len(section["sectionNotes"])
		
		infoString += "NOTES: " + str(noteCount) + "\n"
	
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
	var songName = choiceMenu.options[option]
	songData = loadedJsons[songName]
	
	if (loadedSongs.has(songName)):
		Conductor.play_song(loadedSongs[songName], songData["bpm"], selectedSpeed, false)

	scoreSelect = Conductor.load_score(songName, selectedDifficulty)
	
	if (infoMode):
		var difExt = ""
		match (selectedDifficulty):
			0:
				difExt = "-easy"
			2:
				difExt = "-hard"
	
		songData = Conductor.load_song_json(songName, difExt)
		setup_song_info()

func song_chosen(option):
	var songName = choiceMenu.options[option]
	var difficulty = Main.difficultys[selectedDifficulty].to_lower()
	
	Main.change_playstate(songName, difficulty, selectedSpeed)

func get_freeplay_songs(directory):
	var dir = Directory.new()
	dir.open(directory)
	
	dir.list_dir_begin(true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			if (choiceMenu.options.has(file)):
				return
				
			loadedJsons[file] = Conductor.load_song_json(file)
			
			var songData = loadedJsons[file]
			
			if (songData == null):
				continue
			
			choiceMenu.options.append(file)
			
			var player2 = "test"
			if (songData.has("player2") && Main.CHARACTERS.has(songData["player2"])):
				player2 = songData["player2"]
			
			if (character2 != null):
				character2.queue_free()

			character2 = Main.create_character(player2)
			character2.setup_character()
			
			var textureIcon = character2.iconSheet
			choiceMenu.optionIcons.append(character2.iconSheet)
			
			if (Settings.freeplaySongPreview):
				var newDir = directory + "/" + file + "/Inst.ogg"
				loadedSongs[file] = Mods.mod_ogg(newDir)
