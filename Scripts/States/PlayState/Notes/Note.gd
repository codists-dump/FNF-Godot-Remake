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

var prevSongPos = 0
var realSongPos = 0

func _ready():
	playState = get_tree().current_scene.current_scene

func _process(_delta):
	var moveScale = strum_lane.moveScale
	
	# set the notes position
	if (prevSongPos != Conductor.songPositionMulti):
		realSongPos = Conductor.songPositionMulti
	else:
		realSongPos += _delta
	
	prevSongPos = Conductor.songPositionMulti
	
	var toStrumTime = (strum_time - realSongPos)
	
	position.y = ((toStrumTime * moveScale) * 1000) * (Conductor.scroll_speed) + strum_lane.position.y
	position.x = strum_lane.position.x
	$Sprite.frame = note_type
	
	var worstTiming = playState.HIT_TIMINGS[playState.HIT_TIMINGS.keys()[0]][0]
	
	# detect non-player hits and misses
	if (!missed):
		if (!must_hit || Settings.botPlay):
			if (toStrumTime <= 0):
				note_hit(toStrumTime)
			
		if (toStrumTime * 1000 < -worstTiming):
			note_miss(true)
	else:
		modulate.a = 0.5
		
		if (toStrumTime * 1000 < -worstTiming * 2):
			queue_free()

func note_hit(timing):
	var animPlayer = strum_lane.get_node("AnimationPlayer")
	animPlayer.stop()
	animPlayer.play("hit")
	
	if (!wasHit):
		playState.on_hit(must_hit, note_type, timing)
	
	queue_free()
	
func note_miss(passed):
	playState.on_miss(must_hit, note_type, passed)
	
	missed = true
