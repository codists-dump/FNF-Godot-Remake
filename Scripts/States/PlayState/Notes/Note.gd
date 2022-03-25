extends Node2D

const SCROLL_DISTANCE = 1280 # units
var SCROLL_TIME = Conductor.SCROLL_TIME # sec

enum Note {Left, Down, Up, Right}

export (Note) var note_type = Note.Left

var strum_lane
var strum_time
var sustain_length = 0
var must_hit = false
var dir = 0

var missed = false
var playState

var holdNote = false
var wasHit = false
var held = false

var holdHealth = 0.05

var hasArrowFrames = true

onready var holdWindow = ((60 / Conductor.bpm) / 4)
var changingTweenScale = false

var noteColor

var key = "left"

var holdSprs = {
	"left": Main.get_note_sprite("holdLeft"),
	"down": Main.get_note_sprite("holdDown"),
	"up": Main.get_note_sprite("holdUp"),
	"right": Main.get_note_sprite("holdRight")
}

var desatNoteTexture = Main.get_note_sprite("noteDesat")
var noteOverlayTexture = Main.get_note_sprite("noteDesatOverlay")
var desatHolds = Main.get_note_sprite("holdDesat")

var quantColors = [Color.red, Color.blue, Color.purple, Color.yellow, Color.pink, Color.orange, Color.cyan, Color.green, Color.gray]

var holdArray

var prevSongPos = 0
var realSongPos = 0

func _ready():
	playState = get_tree().current_scene.current_scene
	
	$Sprite.texture = Main.get_note_sprite("note")
	
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
	sustain_length = sustain_length / Conductor.song_speed
	holdNote = sustain_length > 0
	
	if (note_type <= $Sprite.vframes * $Sprite.hframes):
		$Sprite.frame = note_type
	
	setup_note_colors()
	$Line2D.texture = holdArray[0]

func _process(_delta):
	var moveScale = strum_lane.moveScale
	
	# if the note is not being held or just isnt a hold note
	if (!held):
		# set the notes position
		if (prevSongPos != Conductor.songPositionMulti):
			realSongPos = Conductor.songPositionMulti
		else:
			realSongPos += _delta * Conductor.song_speed
		
		prevSongPos = Conductor.songPositionMulti
		
		var toStrumTime = (strum_time - realSongPos)
		
		position.y = ((toStrumTime * moveScale) * 1000) * (Conductor.scroll_speed) + strum_lane.position.y
		position.x = strum_lane.position.x
		
		var worstTiming = playState.HIT_TIMINGS[playState.HIT_TIMINGS.keys()[0]][0]
		
		# detect non-player hits and misses
		if (!missed):
			if (!must_hit || Settings.botPlay):
				if (toStrumTime <= 0):
					note_hit(toStrumTime * 1000)
				
			if (toStrumTime * 1000 < -worstTiming):
				note_miss(true)
		else:
			modulate.a = 0.5
			
			if (toStrumTime * 1000 < -worstTiming * 2):
				queue_free()
	else: # if the note is being held
		# subtract from sustain time
		sustain_length -= _delta
		
		# if completed die
		if (sustain_length <= 0):
			queue_free()
			
		# do funny hold anim wooo
		strum_lane.get_node("AnimationPlayer").play("hit")
		
		# on key release
		if (must_hit && !Settings.botPlay):
			if (!Input.is_action_pressed(key)):
				if (sustain_length <= holdWindow):
					queue_free()
				
				$Sprite.visible = true
				
				held = false
				strum_lane.get_node("AnimationPlayer").play("idle")
				strum_time = Conductor.songPositionMulti
		
		# do character hold anim
		var character = playState.EnemyCharacter
		if (must_hit):
			character = playState.PlayerCharacter
			
		character.idleTimer = 0.2
		
		var animName = playState.player_sprite(note_type, "")
		if (character.get_node("AnimationPlayer").get_current_animation_position() >= 0.03):
			character.play(animName)
	
	if (holdNote):
		# awesome hold note math magic by Scarlett
		var lineY = ((sustain_length * (SCROLL_DISTANCE * Conductor.scroll_speed * Conductor.scroll_speed / SCROLL_TIME) * Conductor.song_speed) - holdArray[1].get_height()) * moveScale
		if (abs(lineY) <= 0):
			lineY = 0
		
		$Line2D.points[1] = Vector2(0, lineY)
		update()

	# overlay
	var overlaySpr = get_node_or_null("Overlay")
	if (overlaySpr != null):
		overlaySpr.visible = $Sprite.visible
		overlaySpr.modulate.a = $Sprite.modulate.a

func _draw():
	if (holdNote):
		var pos = Vector2($Line2D.points[1].x - 25, $Line2D.points[1].y)
		
		var lineHeight = clamp($Line2D.points[1].y, 0, holdArray[1].get_height())
		
		var size = Vector2(holdArray[1].get_size().x, lineHeight)
		var rect = Rect2(pos, size)
		
		var color = $Line2D.modulate
		color.a = $Line2D.default_color.a
		
		draw_texture_rect(holdArray[1], rect, false, color)

func note_hit(timing):
	var animPlayer = strum_lane.get_node("AnimationPlayer")
	animPlayer.stop()
	animPlayer.play("hit")
	
	strum_lane.enemyStrum = !must_hit
	strum_lane.set_color(noteColor)
	
	if (!wasHit):
		playState.on_hit(self, timing)
	
	wasHit = true
	
	if (!holdNote):
		queue_free()
	else:
		$Sprite.visible = false
		position = strum_lane.position
		
		held = true
	
func note_miss(passed):
	playState.on_miss(must_hit, note_type, passed)
	
	missed = true

func setup_note_colors():
	if (hasArrowFrames):
		if (Settings.customNoteColors || Settings.noteQuants):
			if (Settings.noteQuants):
				noteColor = quant_color(strum_time)
			
			$Sprite.modulate = noteColor
			$Sprite.texture = desatNoteTexture
			
			var overlay = Sprite.new()
			overlay.texture = noteOverlayTexture
			overlay.vframes = $Sprite.vframes
			overlay.name = "Overlay"
			overlay.frame = $Sprite.frame
			add_child(overlay, true)
			
			holdArray = desatHolds
			$Line2D.modulate = noteColor

func quant_color(time):
	# some stolen code from forever
	# thx shubs, ari, pixel, and scarlett
	var quantArray = [4, 8, 12, 16, 20, 24, 32, 48, 64]
	
	time *= 1000
	
	var beat = (60 / Conductor.bpm) * 1000
	var measureTime = beat * 4
	var smallestDeviation = measureTime / quantArray[len(quantArray)-1] # fuck if i know

	var color = Color.red
	for quant in len(quantArray):
		var quantTime = (measureTime / quantArray[quant])
		if (fmod(time + smallestDeviation, quantTime) < smallestDeviation * 2):
			return quantColors[quant]
