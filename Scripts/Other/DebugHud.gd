extends CanvasLayer

func _process(delta):
	$FPS.text = "FPS: " + str(Engine.get_frames_per_second())
