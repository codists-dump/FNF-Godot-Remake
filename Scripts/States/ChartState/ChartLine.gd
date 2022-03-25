extends Node2D
tool

const FONT = preload("res://Assets/Other/Fonts/font_event.tres")

var size = Vector2(8, 48)
var squareSize = Vector2(42, 42)

var noteTypes = {
	# TEXTURE, FRAME DIMENSIONS, SIZE
	"": [Main.get_note_sprite("note"), Vector2(250, 250), Vector2(28, 28), true],
	"mine": [Main.get_note_sprite("noteDesat"), Vector2(133, 128), Vector2(0.5, 0.5), false],
	"warn": [Main.get_note_sprite("noteDesat"), Vector2(200, 200), Vector2(0.5, 0.5), false],
}

var lineY = 0
var lineYTo = 0

var mousePos
var freeMove = false

onready var chartState = get_parent()

func _process(delta):
	if Engine.editor_hint:
		return
	
	var clampedSongPos = fmod(chartState.MusicStream.get_playback_position(), (16 * chartState.stepCrochet))
	lineYTo = (clampedSongPos * squareSize.y) / chartState.stepCrochet
	
	if (clampedSongPos < 0.05 || !chartState.MusicStream.playing):
		lineY = lineYTo
	
	lineY = lerp(lineY, lineYTo + 1, delta * 50)

func _draw():
	draw_grid()
	
	if Engine.editor_hint:
		return
	
	draw_position_line()
	draw_cursor()
	
	draw_notes()
	draw_events()

func _input(event):
	if (Engine.editor_hint || !chartState.allowInput):
		return
	
	if (event is InputEventKey):
		if (event.scancode == KEY_SHIFT):
			freeMove = event.pressed

func draw_grid():
	for y in size.y:
		y -= 16
		for x in size.x:
			var rect = Rect2(Vector2(x * squareSize.x, y * squareSize.y), squareSize)
			
			var color = Color("e7e6e6")
			
			var gridVal = abs(y)+abs(x)
			if (gridVal % 2 == 1):
				color = Color("d9d5d5")
			
			if (y > 15):
				color.v -= 0.2
			if (y < 0):
				color.v -= 0.2
			
			if (!Engine.editor_hint):
				if (chartState.curSection == 0):
					if (y < 0):
						continue
			
			draw_rect(rect, color, true)
	
	var lineX = (size.x/2)*squareSize.x
	draw_line(Vector2(lineX, -16 * squareSize.y), Vector2(lineX, size.y * squareSize.y), Color.black, 2)

func draw_notes():
	for section in chartState.songData["notes"]:
		var mustHit = section.get("mustHitSection", false)
		for note in section["sectionNotes"]:
			var texture
			var notePos = Vector2.ZERO
			var color = Color.white
			
			notePos.y = ((note[0] / 1000) / chartState.stepCrochet) - (chartState.curSection * 16)
			notePos.x = note[1]
			
			if (mustHit):
				if (notePos.x < size.x/2):
					notePos.x += 4
				else:
					notePos.x -= 4
			
			if (notePos.y < -16):
				continue
			if (notePos.y > 15):
				color = Color.darkcyan
			if (notePos.y > 31):
				return
			
			if (note[0] < chartState.MusicStream.get_playback_position() * 1000):
				color.a = 0.4
			
			var noteFrame = int(note[1]) % 4
			
			var noteScale = Vector2(28, 28)
			var srcRect = Rect2(0, 250 * noteFrame, 250, 250)
			
			var noteType = ""
			if (len(note) > 3):
				noteType = check_for_notetype(note[3])

			if (noteTypes.has(noteType)):
				var noteTypeData = noteTypes[noteType]
				texture = noteTypeData[0]
				
				srcRect = Rect2(Vector2.ZERO, noteTypeData[1])
				if (noteTypeData[3]):
					srcRect.position = Vector2(0, noteTypeData[1].y * noteFrame)
					
				noteScale = noteTypeData[2]
			
			var rect = Rect2(notePos * squareSize - (noteScale / 2), squareSize + noteScale)
			
			if (texture == null):
				texture = noteTypes[noteTypes.keys()[0]][0]
			
			#draw_line(rect.position, rect.position + Vector2(0, (note[2] * chartState.stepCrochet) * squareSize.y), Color.white, 10)
			
			draw_texture_rect_region(texture, rect, srcRect, color)
			
			draw_string(FONT, rect.position, str(floor((note[0] / 1000) / (16 * chartState.stepCrochet))))
			

func check_for_notetype(noteType):
	var curNote = noteType
			
	match noteType:
		"Hurt Note":
			curNote = "mine"
		"halfBlammed Note":
			curNote = "warn"
	
	if (noteTypes.has(curNote)):
		return curNote
	else:
		return ""

func draw_events():
	for section in chartState.songData["notes"]:
		if (section.has("sectionEvents")):
			for event in section["sectionEvents"]:
				var eventPos = ((event[0] / 1000) / chartState.stepCrochet) - (chartState.curSection * 16)
				
				var eventName = event[1]
				eventName.replace("_", " ")
				eventName = eventName.capitalize()
				
				if (len(event[3]) > 0):
					eventName += " " + str(event[3])
				
				var eventColor = color_from_string(str(event[2]))
				
				if (event[0] < chartState.MusicStream.get_playback_position() * 1000):
					eventColor.a = 0.4
				
				var posY = eventPos * squareSize.y
				draw_line(Vector2(0, posY), Vector2(size.x * squareSize.x, posY), eventColor, 5)
				draw_string(FONT, Vector2(0, posY-2), eventName, eventColor)

func color_from_string(string):
	var values = string.split(",")
	return Color(values[0], values[1], values[2], values[3])

func draw_position_line():
	var camera = $"../Camera"
	camera.position = Vector2(camera.position.x, lineY)
	
	chartState.get_node("ChartStrumLine").position.y = lineY + (squareSize.y / 2)

func draw_cursor():
	if (!chartState.allowInput):
		return
	
	mousePos = get_viewport().get_mouse_position() + $"../Camera".position - position - Vector2(1280, 720) / 2
	mousePos.x = floor(mousePos.x/squareSize.x)*squareSize.x
	if (!freeMove):
		mousePos.y = floor(mousePos.y/squareSize.y)*squareSize.y
	
	if (mousePos.x > (size.x-1) * squareSize.x || mousePos.x < 0):
		return
	
	var rect = Rect2(mousePos, squareSize)
	var color = Color.white
	
	draw_rect(rect, color, true)
