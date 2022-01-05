extends ChoiceMenu

onready var menu = get_node("../")

func _ready():
	optionOffset = Vector2(0, 80)
	
func move_option():
	if (menu.waitTime <= 0):
		.move_option()

func draw_options():
	var idx = 0
	for option in options:
		var sIdx = idx - selected
		
		var color = Color.white
		if (selected != idx):
			color.a = 0.6
		if (!enabled):
			color = Color.webgray
			color.a = 0.6
		
		var data = menu.options[menu.pageName][option]
		
		var string = get_string(data, option)
		
		if (!enabled):
			color = Color.webgray
		
		draw_string(FONT, position + Vector2((sIdx * optionsOffset.x) + 70, (sIdx * optionsOffset.y) + 320) + offset, string.to_upper(), color)
		idx += 1

func get_string(data, option):
	var value = null
	if (data[0] != null):
		value = Settings.get(data[0])
	
	if (data.size()-1 >= 3):
		match (data[3]):
			"seperator":
				return ""
			"key":
				var keys = InputMap.get_action_list(data[0])
				return option + ": " + str(OS.get_scancode_string(keys[keys.size()-1].scancode))
			"percent":
				return option + ": " + str(value * 100)
	
	if (value is Color):
		return option
	
	return option + ": " + str(Settings.get(data[0]))
