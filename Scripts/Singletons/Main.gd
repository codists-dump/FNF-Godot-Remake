extends Node

const MAIN_MENU = preload("res://Scenes/States/MainMenuState.tscn")

const STAGES = {
	"stage": preload("res://Scenes/Stages/Stage.tscn"),
	"halloween": preload("res://Scenes/Stages/Spooky.tscn")
}

const CHARACTERS = {
	"test": preload("res://Scenes/Objects/Character.tscn"),
	"bf": preload("res://Scenes/Objects/Characters/Boyfriend.tscn"),
	"gf": preload("res://Scenes/Objects/Characters/Girlfriend.tscn"),
	"dad": preload("res://Scenes/Objects/Characters/Dad.tscn"),
	"spooky": preload("res://Scenes/Objects/Characters/Spooky_Kids.tscn"),
	"pico": preload("res://Scenes/Objects/Characters/Pico.tscn"),
	
	"codist": preload("res://Scenes/Objects/Characters/Mods/Codist.tscn")
}

var difficultys = ["EASY", "NORMAL", "HARD"]

var mobileMode = false

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	match OS.get_name():
		"Android", "iOS":
			mobileMode = true

func change_scene(path):
	get_tree().current_scene.change_scene(path)
	
func change_to_main_menu():
	var menuSong = load("res://Assets/Music/freakyMenu.ogg")
	if (Conductor.MusicStream.stream != menuSong):
		Conductor.play_song(menuSong, 102, 1)
	
	get_tree().current_scene.change_scene(MAIN_MENU)

func change_playstate(song, difficulty, speed = 1):
	var json = Conductor.load_song_json(song)
	
	# get the stage
	var scene 
	if (json.has("stage") && STAGES.has(json["stage"])):
		scene = STAGES[json["stage"]].instance()
	
	# get the players
	var player1
	var player2
	if (json.has("player1") && CHARACTERS.has(json["player1"])):
		player1 = CHARACTERS[json["player1"]]
	if (json.has("player2") && CHARACTERS.has(json["player2"])):
		player2 = CHARACTERS[json["player2"]]
		
	if (scene == null):
		scene = STAGES["stage"].instance()
		
	scene.song = song
	scene.difficulty = difficulty
	scene.speed = speed
	
	player1 = CHARACTERS['pico']
	
	if (player1 != null):
		scene.PlayerCharacter = player1
	if (player2 != null):
		scene.EnemyCharacter = player2
	
	Main.change_scene(scene)
