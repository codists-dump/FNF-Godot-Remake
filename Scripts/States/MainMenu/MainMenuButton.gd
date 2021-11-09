extends Node2D

var type = 0
var animFrame = 0
var selected = false

func _process(delta):
	animFrame += 15 * delta
	if (animFrame > $Sprite.hframes):
		animFrame = 0
	
	var fakeType = type
	if (selected):
		fakeType = type + ($Sprite.vframes / 2)
	
	$Sprite.frame = (fakeType * $Sprite.hframes) + animFrame
