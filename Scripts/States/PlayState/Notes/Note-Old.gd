extends Node2D

const SCROLL_DISTANCE = 1280 # units
var SCROLL_TIME = Conductor.SCROLL_TIME # sec

enum Note {Left, Down, Up, Right}

export (Note) var note_type = Note.Left

var strum_lane
var strum_time
var sustain_length = 0
var must_hit = false

var missed = false
var playState

var holdNote = false
var wasHit = false
var held = false

var holdHealth = 0.05

var hasArrowFrames = true

onready var holdWindow = ((60 / Conductor.bpm) / 4)
var tweenScale = 1
var changingTweenScale = false

var noteColor

var key = "left"

var holdSprs = {
	"left": [preload("res://Assets/Sprites/Notes/Holds/left_line.png"), preload("res://Assets/Sprites/Notes/Holds/left_end.png")],
	"down": [preload("res://Assets/Sprites/Notes/Holds/down_line.png"), preload("res://Assets/Sprites/Notes/Holds/down_end.png")],
	"up": [preload("res://Assets/Sprites/Notes/Holds/up_line.png"), preload("res://Assets/Sprites/Notes/Holds/up_end.png")],
	"right": [preload("res://Assets/Sprites/Notes/Holds/right_line.png"), preload("res://Assets/Sprites/Notes/Holds/right_end.png")]
}

var desatNoteTexture = preload("res://Assets/Sprites/Notes/Desat_Note_Sprites.png")
var noteOverlayTexture = preload("res://Assets/Sprites/Notes/Desat_Note_Sprites_Overlay.png")
var desatHolds = [preload("res://Assets/Sprites/Notes/Holds/desat_line.png"), preload("res://Assets/Sprites/Notes/Holds/desat_end.png")]

var holdArray

func _ready():
	var songSpeed = get_tree().current_scene.current_scene.speed
	
	SCROLL_TIME = SCROLL_TIME / songSpeed
	sustain_length = sustain_length / Conductor.song_speed
	
	playState = get_tree().current_scene.current_scene
	
	tweenScale = strum_lane.moveScale
	
	if (visible):
		$Tween.interpolate_property(self, "position:y", ((SCROLL_DISTANCE * Conductor.scroll_speed) * tweenScale), 0, SCROLL_TIME / Conductor.scroll_speed)
		$Tween.start()
		
	match note_type:
		Note.Left:
			key = "left"
			noteColor = Settings.noteColorLeft
		Note.Down:
			key = "down"
			noteColor = Settings.noteColorDown
		Note.Up:
			key = "up"
			noteColor = Settings.noteColorUp
		Note.Right:
			key = "right"
			noteColor = Settings.noteColorRight
	
	holdArray = holdSprs[key]
	
	if (sustain_length > 0):
		holdNote = true
		
	setup_note_colors()
	$Line2D.texture = holdArray[0]
		
func setup_note_colors():
	if (hasArrowFrames):
		if (Settings.customNoteColors):
			$Sprite.modulate = noteColor
			$Sprite.texture = desatNoteTexture
			
			var overlay = Sprite.new()
			overlay.texture = noteOverlayTexture
			overlay.vframes = $Sprite.vframes
			overlay.name = "Overlay"
			add_child(overlay, true)
			
			holdArray = desatHolds
			$Line2D.modulate = noteColor
	
func _on_Tween_tween_completed(_object, _key):
	if (changingTweenScale):
		changingTweenScale = false
		return
	
	if (strum_lane != null):
		if (missed):
			note_miss(true)
		
		if (!must_hit || Settings.botPlay):
			note_hit(0)
		else:
			missed = true
			$Tween.interpolate_property(self, "position:y", 0, ((-SCROLL_DISTANCE * Conductor.scroll_speed) * tweenScale), SCROLL_TIME / Conductor.scroll_speed)
			
			if (sustain_length <= 0):
				$Tween.start()

func note_hit(timing):
	var animPlayer = strum_lane.get_node("AnimationPlayer")
	animPlayer.stop()
	animPlayer.play("hit")
	
	if (!wasHit):
		playState.on_hit(must_hit, note_type, timing)
	
	if (!holdNote):
		queue_free()
	else:
		wasHit = true
		held = true
		
		$Sprite.visible = false
		$Tween.stop_all()
	
func note_miss(passed):
	playState.on_miss(must_hit, note_type, passed)
	
	queue_free()

func _process(_delta):
	$Sprite.offset.y = strum_lane.position.y 
	position.x = strum_lane.position.x
	$Line2D.position.y = strum_lane.position.y 
	
	if (strum_lane.moveScale != tweenScale):
		changingTweenScale = true
		
		tweenScale = strum_lane.moveScale
		
		var lastTime = $Tween.tell()
		print(lastTime)
		$Tween.stop_all()
		
		$Tween.interpolate_property(self, "position:y", ((SCROLL_DISTANCE * Conductor.scroll_speed) * tweenScale), 0, (SCROLL_TIME / Conductor.scroll_speed))
		$Tween.start()
		$Tween.seek(lastTime)
	
	if (missed && $Tween.tell() > 0.2):
		if (sustain_length > 0):
			$Tween.stop_all()
			sustain_length -= _delta
			playState.health -= holdHealth
		else:
			$Tween.remove_all()
			note_miss(true)
	
	if (Settings.downScroll):
		scale.y = -1
		
	if (holdNote):
		var multi = 1
		if (Settings.downScroll || tweenScale < 0):
			multi = -1
		
		# awesome hold note math magic by Scarlett
		var lineY = (sustain_length * (SCROLL_DISTANCE * Conductor.scroll_speed * Conductor.scroll_speed / SCROLL_TIME) * multi) - holdSprs[key][1].get_height()
		if (lineY <= 0):
			lineY = 0
		
		$Line2D.points[1] = Vector2(0, lineY)
		update()
		
	if (held):
		$Line2D.position.y = 0
		
		var animPlayer = strum_lane.get_node("AnimationPlayer")
		animPlayer.play("hit")
		
		sustain_length -= _delta
		if (must_hit):
			playState.health += holdHealth
		
		if (sustain_length <= 0):
			queue_free()
			
		position.y = strum_lane.position.y
		
		var character = playState.EnemyCharacter
		if (must_hit):
			character = playState.PlayerCharacter
			
		character.idleTimer = 0.2
		
		var animName = playState.player_sprite(note_type, "")
		if (character.get_node("AnimationPlayer").get_current_animation_position() >= 0.18):
			character.play(animName)
		
		if (must_hit && !Settings.botPlay):
			if (!Input.is_action_pressed(key)):
				if (sustain_length <= holdWindow):
					queue_free()
				held = false
				animPlayer.play("idle")
				$Tween.resume_all()
	
	if (hasArrowFrames):
		$Sprite.frame = note_type
		
		var overlay = get_node_or_null("Overlay")
		if (overlay != null):
			overlay.frame = note_type
			overlay.visible = $Sprite.visible

func _draw():
	if (holdNote):
		var pos = Vector2($Line2D.points[1].x - 25, $Line2D.points[1].y)
		
		var lineHeight = clamp($Line2D.points[1].y, 0, holdArray[1].get_height())
		
		var size = Vector2(holdArray[1].get_size().x, lineHeight)
		var rect = Rect2(pos, size)
		
		var color = $Line2D.modulate
		color.a = $Line2D.default_color.a
		
		draw_texture_rect(holdArray[1], rect, false, color)
