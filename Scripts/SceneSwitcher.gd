extends Node2D

signal scene_loaded()

export (Resource) var main_scene

var current_scene
var next_level
var last_scene

onready var anim = $Transition/AnimationPlayer

func _ready():
	change_scene(main_scene)

func change_scene(scene, transition = true):
	if (scene is Resource):
		next_level = scene.instance()
	elif (scene is Node):
		next_level = scene
	else:
		next_level = load(scene).instance()
	
	if (transition):
		anim.play("fade_in")
	else:
		finish_transition()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fade_in":
			finish_transition()
			
			anim.play("fade_out")

func finish_transition():
	if (current_scene != null):
		current_scene.queue_free()
	
	current_scene = next_level
	add_child(current_scene)
	
	next_level = null
	
	emit_signal("scene_loaded")
