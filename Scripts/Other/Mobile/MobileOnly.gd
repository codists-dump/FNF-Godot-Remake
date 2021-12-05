extends Node

func _ready():
	if (!Main.mobileMode):
		queue_free()
		return
	
	for child in get_children():
		child.visible = true
