extends Node

signal beat_hit()
signal half_beat_hit()

const SCROLL_DISTANCE = 1.6 # units
const SCROLL_TIME = 2 # sec

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
var lastCount = 0

var useCountdown = false

var beatCounter = 1
var halfBeatCounter = 0

var loaded = false
var muteVocals = false

var songPositionMulti = 0

var noteThread
var notesFinished = false

var chartType = null

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
		
	beat_process(delta)
	
	if (notesFinished):
		if (useCountdown):
			countdown_process(delta)
		
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
	
	songData = load_song_json(songName, difExt)
	var songPath = songData["_dir"]
	
	song_speed = speed
	change_bpm(songData["bpm"])
	
	if songData.has("speed"):
		scroll_speed = songData["speed"]
	else:
		scroll_speed = 1 
	
	scroll_speed = sqrt(scroll_speed)
	
	create_notes()
	
	MusicStream.stream = Mods.mod_ogg(songPath + "Inst.ogg")
	MusicStream.pitch_scale = song_speed
	
	if (songData["needsVoices"]):
		VocalStream.stream = Mods.mod_ogg(songPath + "/Voices.ogg")
		VocalStream.pitch_scale = song_speed
	else:
		VocalStream.stream = null
	
	countdown = 3
	useCountdown = true
	
	if (songData.has("type")):
		chartType = songData["type"]
	else:
		chartType = null
	
	#var countDownOffset = get_tree().current_scene.current_scene.notes[0][0] - ((countdown / (bpm / 60)) * 2)
	var countDownOffset = 0
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
		
		var altAnim = false
		if ("altAnim" in section.keys()):
			altAnim = true
		
		var sectionData = [section_time, section["mustHitSection"], altAnim]
		
		sections.append(sectionData)
		
		for note in section["sectionNotes"]:
			var strum_time = (note[0] + Settings.offset) / 1000
			var sustain_length = int(note[2]) / 1000.0
			var direction = int(note[1])
			
			var arg3 = null
			if (len(note) > 3):
				arg3 = note[3] # legit could be anything at this fucking point (mainly used for psych notes)

			if (!section["mustHitSection"]):
				if (direction <= 3):
					direction += 4
				else:
					direction -= 4
					
			var noteData = [strum_time, direction, sustain_length, arg3]
			
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
	
	if (countdown > 0):
		countingDown = true
		countdown -= ((bpm / 60) / 2) * song_speed * delta
	
	if (countingDown):
		var countdownSprite = playState.get_node("HUD/Countdown")
		var stream = playState.get_node("Audio/CountdownStream")
	
		countdownState = ceil((fmod(countdown / 5, countdown) * 10))
		
		if (countdownSprite == null):
			return
		
		countdownSprite.modulate.a -= 3 * delta
		
		match (str(countdownState)):
			"4":
				if (lastCount != 4):
					play_countdown_sound(stream, COUNTDOWN_SOUNDS[0])
				
				lastCount = 4
			"3":
				if (lastCount != 3):
					play_countdown_sound(stream, COUNTDOWN_SOUNDS[1])
					countdownSprite.modulate.a = 1
				
				countdownSprite.visible = true
				countdownSprite.frame = 0
				
				lastCount = 3
			"2":
				if (lastCount != 2):
					play_countdown_sound(stream, COUNTDOWN_SOUNDS[2])
					countdownSprite.modulate.a = 1
				
				countdownSprite.visible = true
				countdownSprite.frame = 1
				
				lastCount = 2
			"1":
				if (lastCount != 1):
					play_countdown_sound(stream, COUNTDOWN_SOUNDS[3])
					countdownSprite.modulate.a = 1
				
				countdownSprite.visible = true
				countdownSprite.frame = 2
				
				lastCount = 1
		
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

func load_song_json(song, difExt=""):
	difExt = difExt.to_lower()
	
	var songPath = "res://Assets/Songs/" + song + "/"
	
	var directory = Directory.new();
	if (!directory.dir_exists(songPath)):
		songPath = Mods.songsDir + "/" + song + "/"
	
	var file = File.new()	
	var jsonPath = songPath + song + difExt + ".json"
	
	if (!file.file_exists(jsonPath)):
		difExt = ""
		jsonPath = songPath + song + difExt + ".json"
	
	if (!file.file_exists(jsonPath)):
		return
	
	file.open(jsonPath, File.READ)
	
	var json = JSON.parse(file.get_as_text()).result["song"]
	json["_dir"] = songPath
	
	return json

func save_score(songName, score):
	var file = ConfigFile.new()
	file.set_value("SCORES", songName, score)
	file.save("user://data.ini")

func load_score(songName):
	var file = ConfigFile.new()
	var err = file.load("user://data.ini")
	
	if err != OK:
		return 0
	
	var score = file.get_value("SCORES", songName, 0)
	return score
