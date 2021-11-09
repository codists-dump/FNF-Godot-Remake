extends Node

const STAGES = {
	"stage": preload("res://Scenes/Stages/Stage.tscn")
}

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func change_scene(path):
	get_tree().current_scene.change_scene(path)

func change_playstate(song, difficulty, speed = 1):
	var scene = STAGES["stage"].instance()
	scene.song = song
	scene.difficulty = difficulty
	scene.speed = speed
	
	Main.change_scene(scene)
