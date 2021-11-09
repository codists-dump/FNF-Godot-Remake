extends CanvasLayer

const BUTTON_SCENE = preload("res://Scenes/States/MainMenu/MainMenuButton.tscn")
var options = {"story": 3, "freeplay": 1, "options": 2, "donate": 0}

var optionsOffset = Vector2(640, 150)

var selected = 0

func _ready():
	createMenuObjects()
	
func createMenuObjects():
	var i = 0
	for option in options:
		var button = BUTTON_SCENE.instance()
		button.type = options[option]
		button.position.y = (i * 140)
		button.position += optionsOffset
		
		add_child(button)
		
		i += 1

func _process(_delta):
	var move = int(Input.is_action_just_pressed("down")) - int(Input.is_action_just_pressed("up"))
	selected += move
	
	if (move != 0):
		get_node("../Sounds/MoveStream").play()
	
	var i = 0
	for button in get_children():
		if (i == selected):
			button.selected = true
		else:
			button.selected = false
		
		i += 1
	
	if (Input.is_action_just_pressed("confirm")):
		get_node("../Sounds/ConfirmStream").play()
		option_logic(options.keys()[selected])

func option_logic(name):
	match (name):
		"story":
			Main.change_playstate("no-villains", "hard")
