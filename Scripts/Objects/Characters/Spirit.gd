extends Character

var trailTimer = 0
var trailSprites = []

func _process(delta):
	if (trailTimer <= 0):
		create_trail_object()
		trailTimer = 0.1
	
	trailTimer -= delta
	
	for trail in trailSprites:
		trail.modulate.a -= 5 * delta
		
		if (trail.modulate.a <= 0):
			trail.queue_free()
			trailSprites.erase(trail)

func create_trail_object():
	var trail = $Sprite.duplicate()

	add_child(trail)
	trailSprites.append(trail)
