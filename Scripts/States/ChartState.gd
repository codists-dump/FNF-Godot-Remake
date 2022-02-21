extends Node2D

var song = "bopeebo"
var dif = ""

const EMPTY_SONG_DATA = {
	"player1": "bf",
	"player2": "dad",
	"song": "",
	"needsVoices": true,
	"speed": 1,
	"bpm": 100,
	"notes": []
}

var songData
var songScript

var crochet
var stepCrochet

var curBeat
var curStep

var lastSection = -1
var curSection = 0

var unhitNotes = []
var allowInput = true

onready var MusicStream = $MusicStream
onready var VocalStream = $VoicesStream

# Called when the node enters the scene tree for the first time.
func _ready():
	Conductor.MusicStream.stop()
	Conductor.VocalStream.stop()
	
	load_song()
	load_music()
	load_song_script()
	
	$HUD/NoteSelect.add_note_types($ChartLine.noteTypes)
	$HUD/CreateEventPopup.add_events()
	$HUD/ChartSideHUD.setup_values()
	
	update()

func _input(event):
	if (!allowInput):
		return
	
	if (event is InputEventKey):
		if (event.pressed):
			var speed = 1
			if (event.shift):
				speed = 4
			
			match (event.scancode):
				KEY_RIGHT:
					change_section(speed)
				KEY_LEFT:
					change_section(-speed)
				KEY_SPACE:
					if (!MusicStream.playing):
						var pos = MusicStream.get_playback_position()
						MusicStream.play(pos)
						VocalStream.play(pos)
						
						reset_hit_notes()
					else:
						MusicStream.stop()
						VocalStream.stop()
				KEY_ESCAPE:
					Main.change_playstate(song, dif, 1, null, true, null, true, MusicStream.get_playback_position() - 2.5 - 0.002)
		else:
			match (event.scancode):
				KEY_E:
					var sectionData = songData["notes"][curSection]
					if (sectionData.has("sectionEvents")):
						var eventTime = ((curStep) * stepCrochet) * 1000
						
						for event in sectionData["sectionEvents"]:
							if (floor(event[0]) == floor(eventTime)):
								sectionData["sectionEvents"].erase(event)
								return
					
					$HUD/CreateEventPopup.popup_centered()
					$HUD/CreateEventPopup.step = curStep
				
	if (event is InputEventMouseButton):
		var moveSpeed = stepCrochet / 4
		match event.button_index:
			BUTTON_WHEEL_UP:
				var posTo = MusicStream.get_playback_position() - moveSpeed
				if (posTo < 0):
					posTo = 0
				change_song_pos(posTo)
			BUTTON_WHEEL_DOWN:
				change_song_pos(MusicStream.get_playback_position() + moveSpeed)
			BUTTON_LEFT:
				if (event.pressed):
					var pos = convert_mouse_pos($ChartLine.mousePos)
					if (pos != null):
						add_note(curSection, pos)

func _process(_delta):
	update_info_text()
	update()
	
	if (MusicStream.playing):
		if (curSection != lastSection):
			reset_hit_notes()
		
		lastSection = curSection
		
		for note in unhitNotes:
			if (note[0] <= MusicStream.get_playback_position() * 1000):
				var strum = $ChartStrumLine/LeftStrum/Buttons
				var noteStr = "Left"
				var noteNode
				
				if (note[1] > 3):
					strum = $ChartStrumLine/RightStrum/Buttons
				
				match str(note[1]):
					"0":
						noteStr = "Left"
					"1":
						noteStr = "Down"
					"2":
						noteStr = "Up"
					"3":
						noteStr = "Right"
					"4":
						noteStr = "Left"
					"5":
						noteStr = "Down"
					"6":
						noteStr = "Up"
					"7":
						noteStr = "Right"
				
				print(note[1])
				noteNode = strum.get_node(noteStr)
				
				if (noteNode != null):
					noteNode.get_node("AnimationPlayer").play("hit")
					noteNode.enemyStrum = true
				
				$HitSoundStream.play()
				unhitNotes.erase(note)
	else:
		if (MusicStream.get_playback_position() > MusicStream.stream.get_length()):
			change_song_pos(0)

	update_section()
	
	curStep = floor(MusicStream.get_playback_position() / stepCrochet);
	curBeat = floor(curStep / 4);

func update():
	.update()
	$ChartLine.update()

func load_song():
	print(songData)
	
	if (songData == null):
		var usedDif = dif
		if (usedDif != ""):
			usedDif = "-"+dif
		
		songData = Conductor.load_song_json(song, usedDif)
	
	change_bpm()

func change_bpm():
	crochet = (60 / songData["bpm"])
	stepCrochet = (crochet / 4)
	
func load_music():
	var songPath = songData["_dir"]
	
	MusicStream.stream = Mods.mod_ogg(songPath + "Inst.ogg")
	print(songPath)
	
	if (songData["needsVoices"]):
		VocalStream.stream = Mods.mod_ogg(songPath + "Voices.ogg")
	else:
		VocalStream.stream = null
	
	change_song_pos(Conductor.MusicStream.get_playback_position())

func update_info_text():
	var infoText = ""
	
	infoText += str(floor(MusicStream.get_playback_position() * 10) / 10)
	infoText += " / " + str(floor(MusicStream.stream.get_length() * 10) / 10)
	
	infoText += "\nSECTION: " + str(curSection)
	
	infoText += "\n\nBEAT: " + str(curBeat)
	infoText += "\nSTEP: " + str(curStep)
	
	$HUD/InfoLabel.text = infoText

func change_section(change):
	var nextSectionTime = ((curSection + 0.001 + change) * (16 * stepCrochet))
	if (nextSectionTime < 0):
		var lastSection = floor(MusicStream.stream.get_length() / (16 * stepCrochet))
		nextSectionTime = lastSection * (16 * stepCrochet)
	
	change_song_pos(nextSectionTime)

func change_song_pos(pos):
	MusicStream.seek(pos)
	VocalStream.seek(pos)

func update_section():
	curSection = floor(MusicStream.get_playback_position() / (16 * stepCrochet))

func reset_hit_notes():
	unhitNotes = []
	var section = songData["notes"][curSection]
	var mustHit = section.get("mustHitSection", false)
	
	for note in section["sectionNotes"]:
		if (note[0] >= (MusicStream.get_playback_position() - 0.1) * 1000):
			var trueNotePos = note[1]
			
			if (mustHit):
				if (trueNotePos < $ChartLine.size.x/2):
					trueNotePos += 4
				else:
					trueNotePos -= 4
			
			unhitNotes.append([note[0], trueNotePos])

func convert_mouse_pos(mousePos):
	var chartLine = $ChartLine
	var pos = mousePos / chartLine.squareSize
	
	if (pos.x > 7):
		return
	if (pos.x < 0):
		return
	if (pos.y < 0):
		return
	if (pos.y > 15):
		return
	
	return pos

func add_note(section, pos):
	var sectionTime = (section * stepCrochet) * 16
	var noteTime = pos.y * stepCrochet
	
	var finalTime = (sectionTime + noteTime) * 1000
	
	var sectionData = songData["notes"][section]
	
	var mustHit = sectionData.get("mustHitSection", false)
	if (mustHit):
		if (pos.x < $ChartLine.size.x/2):
			pos.x += 4
		else:
			pos.x -= 4
	
	var noteData = [finalTime, pos.x, 0]
	
	var noteType = ""
	var selectedItems = $HUD/NoteSelect/ItemList.get_selected_items()
	if (len(selectedItems) == 0):
		selectedItems.append(0)
	noteType = $ChartLine.noteTypes.keys()[selectedItems[0]]
	
	if (noteType != ""):
		noteData.append(noteType)
	
	for note in sectionData["sectionNotes"]:
		if (note[1] == noteData[1] && floor(note[0]) == floor(noteData[0])):
			sectionData["sectionNotes"].erase(note)
			return
	
	sectionData["sectionNotes"].append(noteData)

func add_event(section, step = curStep, eventName = "event", eventColor = Color.red, eventArgs = ""):
	var eventTime = ((step) * stepCrochet) * 1000
	
	var eventArgsArray = []
	for arg in eventArgs.split(","):
		var argString = arg.strip_edges()
		eventArgsArray.append(argString)
	
	var eventData = [eventTime, eventName.to_lower(), eventColor, eventArgsArray]
	var sectionData = songData["notes"][section]
	
	if (!sectionData.has("sectionEvents")):
		songData["notes"][section]["sectionEvents"] = []
	
	songData["notes"][section]["sectionEvents"].append(eventData)

func _on_CreateEventPopup_event_created(step, eventName, eventColor, eventArgs):
	add_event(curSection, step, eventName, eventColor, eventArgs)

func load_song_script():
	var file = Mods.mod_script(Mods.songsDir + "/" + song + "/script.gd")
	if (file is Object):
		songScript = file.new()
