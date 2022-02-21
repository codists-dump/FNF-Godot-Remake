extends "res://Scripts/States/PlayState/Notes/Note.gd"

func _ready():
	holdHealth = 0
	hasArrowFrames = false
	
	holdArray = desatHolds
	$Line2D.modulate = Color.yellow
	$Line2D.texture = holdArray[0]

func setup_note_colors():
	pass

func note_miss(passed):
	.note_miss(passed)
	
	playState.health -= 20.0

func note_hit(timing):
	.note_hit(timing)
	
	if (must_hit):
		var character = playState.PlayerCharacter
	
		if (character != null):
			character.play("dodge")
			character.idleTimer = 0.2
