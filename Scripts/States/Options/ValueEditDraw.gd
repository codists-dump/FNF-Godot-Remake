extends Node2D

var valueEditing = null

func _process(_delta):
	valueEditing = $"../".valueEditing
	
	update()

func _draw():
	if (valueEditing is Vector2):
		draw_circle(valueEditing, 10, Color.white)
