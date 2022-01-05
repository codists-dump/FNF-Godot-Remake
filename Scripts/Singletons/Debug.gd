extends Node

var bpmTestMode = false

onready var debugHud = load("res://Scenes/Other/DebugHud.tscn")

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	var _c_beat = Conductor.connect("beat_hit", self, "beat_hit")

func _input(event):
	if (event is InputEventKey):
		if (event.pressed):
			match (event.scancode):
				KEY_F1:
					var hud = debugHud.instance()
					get_tree().current_scene.add_child(hud)
				KEY_F2:
					bpmTestMode = !bpmTestMode
				KEY_F4:
					OS.window_fullscreen = !OS.window_fullscreen
				KEY_1:
					Mods.load_characters()

func beat_hit():
	if (bpmTestMode):
		get_tree().current_scene.get_node("Music/DebugBPMStream").play()
