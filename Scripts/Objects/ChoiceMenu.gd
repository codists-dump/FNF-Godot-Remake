extends Node2D
class_name ChoiceMenu

signal option_selected(selected)
signal move_option(selected)

const FONT = preload("res://Assets/Other/Fonts/font_alphabet.tres")

export var options = ["OPTION1", "OPTION2", "OPTION3"]
export var optionOffset = Vector2(20, 145)

export var enabled = true

export var useIcons = false
export var optionIcons = []

export var canUseFinder = false

onready var moveStream = AudioStreamPlayer.new()

var selected = 0
var optionsOffset = Vector2(0, 0)
var offset = Vector2.ZERO

var finderString = ""

func _ready():
	add_child(moveStream)
	moveStream.stream = preload("res://Assets/Sounds/scroll_menu.ogg")

func _process(_delta):
	update()
	
	if (enabled):
		move_option()
			
		if (Input.is_action_just_pressed("confirm")):
			emit_signal("option_selected", selected)
	
	offset = lerp(offset, Vector2.ZERO, 20 * _delta)
	optionsOffset = lerp(optionsOffset, optionOffset, 10 * _delta)
	
	var searchLabel = $CanvasLayer/SearchLabel
	if (finderString != ""):
		searchLabel.visible = true
		searchLabel.text = finderString
	else:
		searchLabel.visible = false
	
func _draw():
	draw_options()

func _input(event):
	if (!canUseFinder):
		return
	
	if (event is InputEventKey):
		if (event.control == true):
			if (event.pressed):
				var index = 0
				var charString = OS.get_scancode_string(event.scancode).to_lower()
					
				finderString += charString
				print(finderString)
				
				for option in options:
					var optionName = option.to_lower()
					if (optionName.begins_with(finderString)):
						selected = index
						break
					else:
						index += 1
		if (event.scancode == KEY_CONTROL):
			if (!event.pressed):
				finderString = ""

func draw_options():
	var idx = 0
	for option in options:
		var sIdx = idx - selected
		
		var color = Color.white
		if (selected != idx):
			color.a = 0.6
		if (!enabled):
			color = Color.webgray
			
		var posNew = Vector2((sIdx * optionsOffset.x) + 70, (sIdx * optionsOffset.y) + 320) + offset
		
		draw_string(FONT, position + posNew, option.to_upper(), color)
		
		if (useIcons):
			if (len(optionIcons) >= idx):
				if (optionIcons[idx] != null):
					draw_texture(optionIcons[idx], position + posNew + Vector2(option.length()*55, -30))
		
		idx += 1

func move_option():
	if (Input.is_key_pressed(KEY_CONTROL) && canUseFinder):
		return
	
	var move = int(Input.is_action_just_pressed("down")) - int(Input.is_action_just_pressed("up"))
	if (Input.is_key_pressed(KEY_SHIFT)):
		move *= 5
	selected += move
	
	if (selected > options.size() - 1):
		selected = 0
		move = -move
	elif (selected < 0):
		selected = options.size() - 1
		move = -move
		
	if (move != 0):
		offset = Vector2(optionsOffset.x * move, optionsOffset.y * move)
		emit_signal("move_option", selected)
		moveStream.play()
