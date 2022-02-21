extends CanvasLayer

func _process(delta):
	var string = "FPS: " + str(Engine.get_frames_per_second())
	string += "\nSTEP: " + str(Conductor.curStep)
	string += "\nBEAT: " + str(Conductor.curBeat)
	
	$FPS.text = string
