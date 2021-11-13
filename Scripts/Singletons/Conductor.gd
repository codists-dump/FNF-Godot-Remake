extends Node

signal beat_hit()
signal half_beat_hit()

const SCROLL_DISTANCE = 1.6 # units
const SCROLL_TIME = 5.50 # sec

const COUNTDOWN_SOUNDS = [preload("res://Assets/Sounds/intro3.ogg"),
						preload("res://Assets/Sounds/intro2.ogg"),
						preload("res://Assets/Sounds/intro1.ogg"),
						preload("res://Assets/Sounds/introGo.ogg")]
						
const PLAY_STATE = preload("res://Scenes/States/PlayState.tscn")

var songData

var songName
var songDifficulty

var bpm = 100.0
var scroll_speed = 1
var song_speed = 1

var MusicStream
var VocalStream

var countingDown = false
var countdown = 0
var countdownState = 0

var useCountdown = false

var beatCounter = 1
var halfBeatCounter = 0

var loaded = false
var muteVocals = false

var songPositionMulti = 0

var noteThread
var notesFinished = false

func _ready():
	var streams = get_tree().current_scene.get_node("Music")
	MusicStream = streams.get_node("MusicStream")
	VocalStream = streams.get_node("VocalStream")

	noteThread = Thread.new()
	noteThread.start(self, "create_notes")
	
	var _c_loaded = get_tree().current_scene.connect("scene_loaded", self, "_scene_loaded")

func _scene_loaded():
	loaded = true
	
func _process(delta):
	if !(loaded):
		return
		
	if (muteVocals):
		VocalStream.volume_db = -80
	else:
		VocalStream.volume_db = 0
	
	if (notesFinished):
		beat_process(delta)

		if (useCountdown):
			countdown_process(delta)
			
		song_finished_check()
		
	var countdownMulti = ((countdown / (bpm / 60)) * 2)
	songPositionMulti = MusicStream.get_playback_position() - countdownMulti

func _exit_tree():
	noteThread.wait_to_finish()

func play_song(song, newerBpm, speed = 1):
	song_speed = speed
	change_bpm(newerBpm)
	
	if (song is Object):
		MusicStream.stream = song
	else:
		MusicStream.stream = load(song)
	MusicStream.pitch_scale = song_speed
	MusicStream.play()
	
	VocalStream.stop()
	
	useCountdown = false

func play_chart(song, difficulty, speed = 1):
	songName = song
	
	var difExt = "-" + difficulty
	
	match difficulty:
		"easy":
			songDifficulty = 0
		"normal":
			songDifficulty = 0
			difExt = ""
		"hard":
			songDifficulty = 0
			
	var songPath = "res://Assets/Songs/" + songName  + "/"
	songData = load_song_json(songName, difExt, songPath)
	
	song_speed = speed
	change_bpm(songData["bpm"])
	
	if songData.has("speed"):
		scroll_speed = songData["speed"]
	else:
		scroll_speed = 1 
		
	create_notes()
	
	MusicStream.stream = load(songPath + "Inst.ogg")
	MusicStream.pitch_scale = song_speed
	
	if (songData["needsVoices"]):
		VocalStream.stream = load(songPath + "/Voices.ogg")
		VocalStream.pitch_scale = song_speed
	else:
		VocalStream.stream = null
	
	countdown = 2.8
	useCountdown = true
	
	var countDownOffset = get_tree().current_scene.current_scene.notes[0][0] - ((countdown / (bpm / 60)) * 2)
	if (countDownOffset < 0):
		countdown -= countDownOffset

func change_bpm(newBpm):
	bpm = float(newBpm)
	
	beatCounter = 1

func create_notes():
	notesFinished = false
	
	var playState = get_tree().current_scene.current_scene
	
	var temp_array = []
	var section_array = []
	var last_note
	
	var sections = []
	
	for section in songData["notes"]:
		var section_time = (((60 / bpm) / 4) * 16) * sections.size()
		var sectionData = [section_time, section["mustHitSection"]]
		
		sections.append(sectionData)
		
		for note in section["sectionNotes"]:
			var strum_time = (note[0] + Settings.offset) / 1000
			var sustain_length = int(note[2]) / 1000.0
			var direction = int(note[1])

			if (!section["mustHitSection"]):
				if (direction <= 3):
					direction += 4
				else:
					direction -= 4
					
			var noteData = [strum_time, direction, sustain_length]
			
			if (last_note != null):
#				if (last_note[0] == strum_time):
#					last_note[1] += 1
#					section_array.append(last_note)
				temp_array.append(last_note)
				if (!section_array.empty()):
					temp_array.append_array(section_array)
					section_array = []
				last_note = noteData
			else:
				last_note = noteData
				
	temp_array.append(last_note)
	
	var strum_times = []
	
	for tmp_note in temp_array:
		strum_times.append(tmp_note[0])
		
	strum_times.sort()
		
	var notes = []
		
	while !temp_array.empty():
		var index = 0
		
		while strum_times[0] != temp_array[index][0]:
			index += 1
		
		notes.append(temp_array[index])
		
		strum_times.remove(0)
		temp_array.remove(index)
		
	playState.notes = notes
	playState.sections = sections
	
	notesFinished = true

func countdown_process(delta):
	var playState = get_tree().current_scene.current_scene
	var countdownSprite = playState.get_node("HUD/Countdown")
	var stream = playState.get_node("Audio/CountdownStream")
	
	if (countdown > 0):
		countingDown = true
		countdown -= ((bpm / 60) / 2) * song_speed * delta
	
	if (countingDown):
		countdownState = ceil((fmod(countdown / 5, countdown) * 10))
		
		match (str(countdownState)):
			"4":
				play_countdown_sound(stream, COUNTDOWN_SOUNDS[0])
			"3":
				play_countdown_sound(stream, COUNTDOWN_SOUNDS[1])
				countdownSprite.visible = true
				countdownSprite.frame = 0
			"2":
				play_countdown_sound(stream, COUNTDOWN_SOUNDS[2])
				countdownSprite.visible = true
				countdownSprite.frame = 1
			"1":
				play_countdown_sound(stream, COUNTDOWN_SOUNDS[3])
				countdownSprite.visible = true
				countdownSprite.frame = 2
		
		if (countdown <= 0):
			start_song()
			
			countdownSprite.visible = false
			
			countingDown = false
			countdown = 0
			
func start_song():
	MusicStream.play()
	VocalStream.play()
	
	change_bpm(bpm)

func play_countdown_sound(stream, snd):
	if (stream.stream != snd):
		stream.stream = snd
		stream.play()

func beat_process(delta):
	beatCounter -= ((bpm / 60) * song_speed) * delta
	
	if (beatCounter <= 0):
		beatCounter = beatCounter + 1
		halfBeatCounter += 1
		emit_signal("beat_hit")
		
		if (halfBeatCounter >= 2):
			emit_signal("half_beat_hit")
			halfBeatCounter = 0

func song_finished_check():
	if (MusicStream.get_playback_position() >= MusicStream.stream.get_length()):
		Main.change_to_main_menu()

func load_song_json(song, difExt="", songPath = null):
	if (songPath == null):
		songPath = "res://Assets/Songs/" + song  + "/"
	
	var file = File.new()
	file.open(songPath + song + difExt + ".json", File.READ)
	
	return JSON.parse(file.get_as_text()).result["song"]
