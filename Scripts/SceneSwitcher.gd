extends Node2D

signal scene_loaded()

export (Resource) var main_scene

var current_scene
var next_level

onready var anim = $Transition/AnimationPlayer

func _ready():
	change_scene(main_scene)

func change_scene(scene):
	if (scene is Resource):
		next_level = scene.instance()
	elif (scene is Node):
		next_level = scene
	else:
		next_level = load(scene).instance()
	
	anim.play("fade_in")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fade_in":
			if (current_scene != null):
				current_scene.queue_free()
			
			current_scene = next_level
			add_child(current_scene)
			
			next_level = null
			
			anim.play("fade_out")
			
			emit_signal("scene_loaded")
