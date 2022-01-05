extends Node2D

var curColor = Color.white

# icon, portrait, color, description, art credits, link
var credits = {
				"codist": ["codist", "codist", Color(0.72549, 0.14902, 0.380392), "Creator of FNF Godot", "Icon by @Palladium346, art by @Hzx_Gato", "https://twitter.com/ImCodist"],
				"Yoshubs": ["shubs", "shubs", Color(0.266667, 0.580392, 0.901961), "Programming Help / Forever Engine", "Icon by @RiverOaken, art by @SVortex1232", "https://twitter.com/yoshubs"],
				"Pixloen": ["pixel", null, Color.blue, "Forever Engine Assets", "Art by @", "https://twitter.com/exlinfnf"],
				"Gedehari": ["gedehari", null, Color(1.0, 0.576471, 0), "Programming Help", "Icon by @RiverOaken, art by @", "https://twitter.com/gedehari"],
				"MrIDCrisis": ["kuu", "kuu", Color(0.541176, 0.231373, 0.905882), "existed", "Art by @Yoshubs", "https://twitter.com/MrIDCrisis"]
			}

func _ready():
	$ChoiceMenu.options = []
	$ChoiceMenu.connect("move_option", self, "person_changed")
	$ChoiceMenu.connect("option_selected", self, "person_selected")
	
	for person in credits.keys():
		var personData = credits[person]
		var iconPath = personData[0]
		var portPath = personData[1]
		
		$ChoiceMenu.options.append(person)
		
		if (iconPath != null):
			$ChoiceMenu.optionIcons.append(load("res://Assets/Sprites/Credits/Icons/"+iconPath+".png"))
		else:
			$ChoiceMenu.optionIcons.append(null)
		
		if (portPath != null):
			credits[person][1] = load("res://Assets/Sprites/Credits/Portraits/"+portPath+".png")
		
	person_changed(0)

func _process(delta):
	$Background.modulate = lerp($Background.modulate, curColor, 5*delta)
	$Info/Portrait.offset.y = lerp($Info/Portrait.offset.y, 0, 10*delta)
	
	if (Input.is_action_just_pressed("cancel")):
		$CancelStream.play()
		Main.change_scene(Main.MAIN_MENU)

func person_changed(selected):
	var person = credits.keys()[selected]
	var personData = credits[person]
	
	curColor = personData[2]
	
	$Info/Portrait.texture = personData[1]
	$Info/Portrait.offset.y += 20
	
	$Info/InfoLabel.text = person + "\n" + personData[3]
	$Info/Credits.text = personData[4]

func person_selected(selected):
	var person = credits.keys()[selected]
	var personData = credits[person]
	
	OS.shell_open(personData[5])
