extends Node

const MAIN_MENU = preload("res://Scenes/States/MainMenuState.tscn")

const STAGES = {
	"stage": preload("res://Scenes/Stages/Stage.tscn")
}

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func change_scene(path):
	get_tree().current_scene.change_scene(path)
	
func change_to_main_menu():
	var menuSong = load("res://Assets/Music/freakyMenu.ogg")
	if (Conductor.MusicStream.stream != menuSong):
		Conductor.play_song(menuSong, 102, 1)
	
	get_tree().current_scene.change_scene(MAIN_MENU)

func change_playstate(song, difficulty, speed = 1, stage = null):
	var json = Conductor.load_song_json(song)
	
	var scene
	if (stage == null):
		var songStage = "stage"
		if (json.has(["stage"]) && STAGES.has(json["stage"])):
			songStage = json["stage"]
			
		scene = STAGES[songStage].instance()
	else:
		scene = load(scene).instance()
		
	scene.song = song
	scene.difficulty = difficulty
	scene.speed = speed
	
	Main.change_scene(scene)
