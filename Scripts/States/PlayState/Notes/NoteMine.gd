extends "res://Scripts/States/PlayState/Notes/Note.gd"

func _ready():
	holdHealth = 0
	hasArrowFrames = false
	
	holdArray = desatHolds
	$Line2D.modulate = Color.gray
	$Line2D.texture = holdArray[0]
	
func setup_note_colors():
	pass

func note_miss(passed):
	queue_free()

func note_hit(timing):
	if (must_hit && !Settings.botPlay):
		playState.on_miss(must_hit, note_type, true)
		queue_free()
	else:
		missed = true
		$Tween.interpolate_property(self, "position:y", 0, -SCROLL_DISTANCE * Conductor.scroll_speed, SCROLL_TIME / Conductor.scroll_speed)
		
		if (sustain_length <= 0):
			$Tween.start()
	
	if (must_hit):
		var character = playState.PlayerCharacter
		
		if (character != null):
			character.play("hit")
