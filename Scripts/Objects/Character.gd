tool
extends Node2D
class_name Character

export (bool) var flipX = false
export (Vector2) var spriteScale = Vector2(1, 1)
export (bool) var idleDance = false
export (bool) var idleDanceSpeed = false
export (Vector2) var camOffset = Vector2(0, 0)
export (bool) var girlfriendPosition = false
export (bool) var hasAlt = false

export (Resource) var iconSheet = preload("res://Assets/Sprites/Characters/Icons/icon-face.png")
export (Color) var characterColor = Color.yellow

var lastIdleDance = null

var idleTimer = 0
var animTimer = 0

var useAlt = false

var animAddon = ""

func _ready():
	if Engine.editor_hint:
		return
	
	if !(idleDance):
		var _c_half_beat = Conductor.connect("half_beat_hit", self, "idle_dance")
	else:
		var _c_beat = Conductor.connect("beat_hit", self, "idle_dance")
		lastIdleDance = "danceLEFT"
		
	if (flipX):
		camOffset.x = -camOffset.x

func _process(_delta):
	if (flipX):
		scale = Vector2(-1 * spriteScale.x, spriteScale.y)
	else:
		scale = spriteScale
	
	if Engine.editor_hint:
		return
		
	if (idleTimer > 0):
		idleTimer -= _delta
	if (animTimer > 0):
		animTimer -= _delta

func play(animName, newAnimTimer = 0):
	if (animTimer > 0):
		return
	
	if ($AnimationPlayer.has_animation(animName+animAddon)):
		animName = animName+animAddon
	
	if (flipX):
		match (animName):
			"singLEFT":
				animName = "singRIGHT"
			"singRIGHT":
				animName = "singLEFT"
			"singLEFTMiss":
				animName = "singRIGHTMiss"
			"singRIGHTMiss":
				animName = "singLEFTMiss"
	
	if (hasAlt):
		if (useAlt):
			if (animName != get_idle_anim()):
				animName += "-alt"
	
	if ($AnimationPlayer.has_animation(animName)):
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play(animName)
		
		animTimer = newAnimTimer
		idleTimer = 0.5
	
func idle_dance():
	if (animTimer > 0):
		return
	
	if (get_idle_anim() == "idle"):
		if (idleTimer <= 0):
			$AnimationPlayer.stop()
			$AnimationPlayer.play(get_idle_anim())
	else:
		if ($AnimationPlayer.assigned_animation == "danceLEFT" || $AnimationPlayer.assigned_animation == "danceRIGHT"):
			var bpmSpeed = 1
			if (idleDanceSpeed):
				bpmSpeed = (Conductor.bpm * Conductor.song_speed) / 120
			
			if (lastIdleDance == "danceLEFT"):
				$AnimationPlayer.play("danceRIGHT", -1, bpmSpeed)
			elif (lastIdleDance == "danceRIGHT"):
				$AnimationPlayer.play("danceLEFT", -1, bpmSpeed)
				
			lastIdleDance = $AnimationPlayer.assigned_animation
			
func _on_AnimationPlayer_animation_finished(anim_name):
	if Engine.editor_hint:
		return
	
	if (anim_name != get_idle_anim()):
#		if (get_idle_anim() == "idle"):
#			$AnimationPlayer.play(get_idle_anim(), -1, 1, true)
#		else:
		if (get_idle_anim() != "idle"):
			match (anim_name):
				"singRIGHT":
					$AnimationPlayer.play("danceRIGHT")
					lastIdleDance = "danceLEFT"
				"singLEFT":
					$AnimationPlayer.play("danceLEFT")
					lastIdleDance = "danceRIGHT"
				_:
					$AnimationPlayer.play(lastIdleDance)

func get_idle_anim():
	if (idleDance):
		if ($AnimationPlayer.has_animation("danceLEFT")):
			return "danceLEFT"
	
	return "idle"

func setup_character():
	pass
