tool
extends Node2D

enum Note {Left, Down, Up, Right}
export (Note) var note_type = Note.Left
export (int) var animFrame = 0
var enemyStrum = false

var desatTexture = preload("res://Assets/Sprites/Notes/Desat_Strum_Sprites.png")
var overlayTexture = preload("res://Assets/Sprites/Notes/Desat_Strum_Sprites_Overlay.png")
var noteColor

func _ready():
	setup_colors()

func setup_colors():
	match note_type:
		Note.Left:
			noteColor = Settings.noteColorLeft
		Note.Down:
			noteColor = Settings.noteColorDown
		Note.Up:
			noteColor = Settings.noteColorUp
		Note.Right:
			noteColor = Settings.noteColorRight
	
	if (Settings.customNoteColors):
		$Sprite.modulate = noteColor
		$Sprite.texture = desatTexture
		
		var overlay = Sprite.new()
		overlay.texture = overlayTexture
		overlay.vframes = $Sprite.vframes
		overlay.hframes = $Sprite.hframes
		overlay.name = "Overlay"
		add_child(overlay, true)

func _process(_delta):
	if not Engine.editor_hint:
		if (Settings.downScroll):
			scale.y = -1
	
	$Sprite.frame = animFrame + (note_type * 6)
	
	var overlay = get_node_or_null("Overlay")
	if (overlay != null):
		overlay.frame = $Sprite.frame

func _on_AnimationPlayer_animation_finished(anim_name):
	if (!enemyStrum && !Settings.botPlay):
		return
		
	if (anim_name == "hit"):
		$AnimationPlayer.play("idle")
