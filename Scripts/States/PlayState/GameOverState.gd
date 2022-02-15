extends Node2D

const GAMEOVER_MUSIC = preload("res://Assets/Music/gameOver.ogg")

var died = false
var doBop = false
var pressed = false

var song = "tutorial"
var difficulty = "hard"
var speed = 1
var storySongs = false

var pos = 0

func _ready():
	var _connect = Conductor.connect("half_beat_hit", self, "beat")
	
func _input(event):
	if (!pressed):
		if (event.is_action_pressed("confirm")):
			Conductor.MusicStream.stop()
			Conductor.VocalStream.stop()
			
			$EndStream.play()
			
			died = true
			doBop = false
			pressed = true
			$AnimationPlayer.play("confirm")
	
	if (event.is_action_pressed("cancel")):
		Conductor.MusicStream.stop()
		Conductor.VocalStream.stop()
		
		Main.change_to_main_menu()
	
func _process(_delta):
	if (died):
		$Camera2D.position = $DeathSprite.position

func _on_AnimationPlayer_animation_finished(anim_name):
	match (anim_name):
		"die":
			died = true
			doBop = true
			
			if (Conductor.MusicStream.stream != GAMEOVER_MUSIC):
				Conductor.play_song(GAMEOVER_MUSIC, 100, 1)
			
			$AnimationPlayer.play("bop")
		"confirm":
			Main.change_playstate(song, difficulty, speed, storySongs, true)

func beat():
	if (doBop):
		$AnimationPlayer.play("bop")
