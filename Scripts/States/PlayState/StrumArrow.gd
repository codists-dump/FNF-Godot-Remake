tool
extends Node2D

enum Note {Left, Down, Up, Right}
export (Note) var note_type = Note.Left
export (int) var animFrame = 0
var enemyStrum = false

var desatTexture = preload("res://Assets/Sprites/Notes/Desat_Strum_Sprites.png")
var overlayTexture = preload("res://Assets/Sprites/Notes/Desat_Strum_Sprites_Overlay.png")
var noteColor = Color.white

var customTexture = false

var moveScale = 1

func _ready():
	if not Engine.editor_hint:
		setup_colors()

func setup_colors():
	if (customTexture):
		return
	
	if (Settings.customNoteColors || Settings.noteQuants):
		match note_type:
			Note.Left:
				noteColor = Settings.noteColorLeft
			Note.Down:
				noteColor = Settings.noteColorDown
			Note.Up:
				noteColor = Settings.noteColorUp
			Note.Right:
				noteColor = Settings.noteColorRight
		
		var overlay = Sprite.new()
		overlay.texture = overlayTexture
		overlay.vframes = $Sprite.vframes
		overlay.hframes = $Sprite.hframes
		overlay.name = "Overlay"
		add_child(overlay, true)
		
		set_color()

func set_color(color=noteColor):
	if (customTexture):
		return
	
	if (Settings.customNoteColors || Settings.noteQuants):
		noteColor = color
		
		$Sprite.modulate = color
		$Sprite.texture = desatTexture

func _process(_delta):
	$Sprite.frame = animFrame + (note_type * 6)
	
	var overlay = get_node_or_null("Overlay")
	if (overlay != null):
		overlay.frame = $Sprite.frame
		overlay.position = $Sprite.position
		overlay.offset = $Sprite.offset

func _on_AnimationPlayer_animation_finished(anim_name):
	if (!enemyStrum && !Settings.botPlay):
		return
		
	if (anim_name == "hit"):
		$AnimationPlayer.play("idle")
