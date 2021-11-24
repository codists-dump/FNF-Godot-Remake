extends Node

func _ready():
	if (!Main.mobileMode):
		queue_free()
