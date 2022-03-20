extends Node
class_name ModScript

# setup variables
# you can use most of these, tho using some of these arent
# advised if you dont know what ur doin
var playState

var playerStrum
var enemyStrum

var playerCharacter
var enemyCharacter
var gfCharacter

var playerPosition
var enemyPosition
var gfPosition
var ratingPosition

var camera
var background
var foreground
var characters
var hud

var curStep
var curBeat

# functions and setup junk
func _ready():
	playerStrum = playState.PlayerStrum
	enemyStrum = playState.EnemyStrum
	
	playerCharacter = playState.PlayerCharacter
	enemyCharacter = playState.EnemyCharacter
	gfCharacter = playState.GFCharacter
	
	playerPosition = playState.get_node("Positions/Player")
	enemyPosition = playState.get_node("Positions/Enemy")
	gfPosition = playState.get_node("Positions/Girlfriend")
	ratingPosition = playState.get_node("Positions/Rating")
	
	camera = playState.get_node("Camera")
	background = playState.get_node("Background")
	foreground = playState.get_node("Foreground")
	characters = playState.get_node("Characters")
	hud = playState.get_node("HUD/HudElements")
	
	Conductor.connect("on_step", self, "_on_step")
	Conductor.connect("on_beat", self, "_on_beat")
	
	playState.connect("event_activated", self, "_on_event")
	playState.connect("note_hit", self, "_on_note_hit")
	playState.connect("note_missed", self, "_on_note_missed")
	playState.connect("note_created", self, "_on_note_created")

func _process(_delta):
	curStep = Conductor.curStep
	curBeat = Conductor.curBeat

func _on_step(_step):
	pass

func _on_beat(_beat):
	pass

func _tween_finished(_object, _key):
	pass

func _clear_tween(_object, _key):
	pass
	
func _on_event(_event, _args):
	pass

func _on_note_hit(_rating, _must_hit, _note_type, _timing):
	pass
	
func _on_note_missed():
	pass

func _on_note_created(_note):
	pass

# Tween a node's property from a start value to a end value.
# ex. tween(node, "position:y", 0, 100, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
func tween(node, property, start_value, end_value, duration, trans_type = 0, ease_type = 2):
	var tween = Tween.new()
	
	tween.connect("tween_completed", self, "_tween_finished")
	tween.connect("tween_completed", self, "_clear_tween")
	
	add_child(tween)
	tween.interpolate_property(node, property,
		start_value, end_value, duration,
		trans_type, ease_type)
	tween.start()
	
	return tween

# Zoom the camera to the defined zoom value. If instant is false the camera will tween to the zoom value.
# ex. zoom_camera(0.8, false, 0.4)
func zoom_camera(zoom, instant = false, speed = 0.5):
	var zoomVector = Vector2(zoom, zoom)
	if !(instant):
		tween(camera, "zoom", camera.zoom, zoomVector, speed, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	else:
		camera.zoom = zoomVector

# Creates a sprite.
func create_sprite(path, position=Vector2.ZERO):
	var spr = Sprite.new()

	spr.texture = Mods.mod_image(path)
	spr.position = position

	return spr

# Creates a sprite using a xml file.
func create_atlas_sprite(path, position=Vector2.ZERO):
	var node = Node2D.new()
	var spr = Sprite.new()

	Mods.add_sparrow_atlas(spr, path)
	spr.position = position

	spr.name = "Sprite"
	node.add_child(spr, true)

	return node

# Add a animation to a atlas sprite.
func add_by_prefix(node, dir, name, xmlName, offset=[0,0], step=0.05, loops=false):
	var animPlayer = node.get_node_or_null("AnimationPlayer")
	
	if (animPlayer == null):
		animPlayer = AnimationPlayer.new()
		animPlayer.name = "AnimationPlayer"
		node.add_child(animPlayer, true)
	
	Mods.add_by_prefix(animPlayer, dir, name, xmlName, offset, step, loops)

func play_animation(node, animation):
	var animPlayer = node.get_node_or_null("AnimationPlayer")
	
	if (animPlayer == null):
		return
	
	animPlayer.stop()
	animPlayer.play(animation)
