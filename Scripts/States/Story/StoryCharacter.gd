extends Sprite

var character

var animArray = [0]

var curFrame = 0
var nextFrame = 0
var speed = 1

var gfState = true

func _process(delta):
	nextFrame += delta * (10 * speed)
	
	if (nextFrame >= 1):
		nextFrame -= 1
		
		if (curFrame < len(animArray) - 1):
			curFrame += 1
	
	if (curFrame > len(animArray) - 1):
		curFrame = 0

	frame = animArray[curFrame]

func play(array, force = false, newSpeed = 1):
	
	if (array == animArray && !force):
		return
	
	animArray = array
	
	speed = newSpeed
	nextFrame = 0
	curFrame = 0
