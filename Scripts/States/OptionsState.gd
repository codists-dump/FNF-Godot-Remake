extends Node2D

func _process(_delta):
	if (!$OptionsMenu.enabled):
		return
	
	if (Input.is_action_just_pressed("cancel")):
		$OptionsMenu/Sounds/CancelStream.play()
		Main.change_scene(Main.MAIN_MENU)
