extends Node

const MAIN_MENU = preload("res://Scenes/States/MainMenuState.tscn")
const CHART_EDITOR = preload("res://Scenes/States/ChartState.tscn")
const VOLUME_HUD = preload("res://Scenes/Other/VolumeHud.tscn")

var STAGES = {
	"stage": preload("res://Scenes/Stages/Stage.tscn"),
	"halloween": preload("res://Scenes/Stages/Spooky.tscn")
}

var CHARACTERS = {
	"test": preload("res://Scenes/Objects/Character.tscn"),
	"bf": preload("res://Scenes/Objects/Characters/Boyfriend.tscn"),
	"gf": preload("res://Scenes/Objects/Characters/Girlfriend.tscn"),
	"dad": preload("res://Scenes/Objects/Characters/Dad.tscn"),
	"spooky": preload("res://Scenes/Objects/Characters/Spooky_Kids.tscn"),
	"pico": preload("res://Scenes/Objects/Characters/Pico.tscn"),
	"mom": preload("res://Scenes/Objects/Characters/Mom.tscn"),
	
	"bf-car": preload("res://Scenes/Objects/Characters/Boyfriend-Car.tscn"),
	"mom-car": preload("res://Scenes/Objects/Characters/Mom-Car.tscn"),
	
	"parents-christmas": preload("res://Scenes/Objects/Characters/Parents-Christmas.tscn"),
}

var difficultys = ["EASY", "NORMAL", "HARD"]

var mobileMode = false
var forcePlayer1 = null
var forcePlayer2 = null

var audioLevel = 5
var audioArray = [0, -5, -10, -15, -20, -25, -30, -35, -40, -45, -80]
var volumeHUD

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	match OS.get_name():
		"Android", "iOS":
			mobileMode = true
	
	volumeHUD = VOLUME_HUD.instance()
	get_tree().current_scene.call_deferred("add_child", volumeHUD)
	AudioServer.set_bus_volume_db(0, audioArray[audioLevel])

func _input(event):
	if (event is InputEventKey):
		if (event.pressed):
			var change = 0
			match (event.scancode):
				KEY_MINUS:
					change = 1
				KEY_EQUAL:
					change = -1
			
			if (change != 0):
				audioLevel += change
				audioLevel = clamp(audioLevel, 0, len(audioArray)-1)
				
				AudioServer.set_bus_volume_db(0, audioArray[audioLevel])
				
				volumeHUD.update_volume()

func change_scene(path, transition=true):
	get_tree().current_scene.change_scene(path, transition)
	
func change_to_main_menu():
	var menuSong = load("res://Assets/Music/freakyMenu.ogg")
	if (Conductor.MusicStream.stream != menuSong):
		Conductor.play_song(menuSong, 102, 1)
	
	get_tree().current_scene.change_scene(MAIN_MENU)

func change_playstate(song, difficulty, speed = 1, storySongs = null, transition = true, prevState = null, chartingMode = false, startingPosition = 0):
	var json = Conductor.load_song_json(song)
	if (chartingMode):
		json = Conductor.songData
	
	# get the stage
	var scene 
	if (json.has("stage") && STAGES.has(json["stage"])):
		scene = STAGES[json["stage"]].instance()
	
	# get the players
	var player1
	var player2
	if (json.has("player1") && CHARACTERS.has(json["player1"])):
		player1 = json["player1"]
	if (json.has("player2") && CHARACTERS.has(json["player2"])):
		player2 = json["player2"]
		
	if (scene == null):
		scene = STAGES["stage"].instance()
		
	scene.song = song
	scene.difficulty = difficulty
	scene.speed = speed
	
	scene.chartingMode = chartingMode
	
	if (startingPosition < 0):
		startingPosition = 0
	Conductor.startingPosition = startingPosition
	
	if (forcePlayer1 != null):
		player1 = forcePlayer1
	if (forcePlayer2 != null):
		player2 = forcePlayer2
	
	if (player1 != null):
		scene.PlayerCharacter = player1
	if (player2 != null):
		scene.EnemyCharacter = player2
		
	if (storySongs != null):
		scene.storyMode = true
		var _oldSong = storySongs.pop_front()
		scene.storySongs = storySongs
		
		print(storySongs)
	
	if (prevState != null):
		if (prevState.has("camPos")):
			print(prevState["camPos"])
			scene.get_node("Camera").position = prevState["camPos"]
		if (prevState.has("oldHealth")):
			scene.oldHealth = prevState["oldHealth"]
		
	Main.change_scene(scene, transition)

func change_chart_state(song=null, difficulty=null):
	var scene = CHART_EDITOR.instance()
	
	if (song != null):
		Conductor.songName = song
	if (difficulty != null):
		Conductor.songDifficulty = difficulty
	
	if (Conductor.songName != null):
		scene.song = Conductor.songName
	if (Conductor.songDifficulty != null):
		scene.dif = difficultys[Conductor.songDifficulty]
	if (Conductor.songData != null):
		scene.songData = Conductor.songData
	
	Main.change_scene(scene, false)

func create_character(character):
	var scene = Main.CHARACTERS[character]
	if (scene is GDScript):
		return scene.new()
	else:
		return scene.instance()

# stole from literally just tetris no way tetris reference
func convert_to_time_string(time):
	var minutes = floor(time / 60)
	var seconds = int(time) % 60
	
	return str(minutes) + ":" + "%02d" % seconds
