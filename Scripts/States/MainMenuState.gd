extends Node2D

func _ready():
	Conductor.play_song("res://Assets/Music/freakyMenu.ogg", 102, 1)

func _process(delta):
	var optionsSize = $MainMenuOptions.options.keys().size()
	var offset = $MainMenuOptions.selected - (optionsSize / 2)
	
	$Camera2D.position = Vector2(0, (offset * 15))
