extends Node2D

const BUTTON_SCENE = preload("res://Scenes/States/Story/StoryButton.tscn")

# songs, image_name, week_name, character, opponent, girlfre
var weeks = {
	"tutorial": [["tutorial"], "tutorial", "", "bf", "", "gf"],
	"week1": [["bopeebo", "fresh", "dad-battle"], "week1", "Daddy Dearest", "bf", "dad", "gf"],
	"week2": [["spookeez", "south", "monster"], "week2", "Spooky Month", "bf", "spooky", "gf"],
	"week3": [["pico", "philly-nice", "blammed"], "week3", "Pico", "bf", "pico", "gf"],
	"week4": [["satin-panties", "high", "milf"], "week4", "Mommy Must Murder", "bf", "mom", "gf"],
	"week5": [["cocoa", "eggnog", "winter-horrorland"], "week5", "Red Snow", "bf", "parents", "gf"],
	"week6": [["senpai", "roses", "thorns"], "week6", "Hating Simulator ft. Moawling", "bf", "senpai", "gf"],
}

# image_name, type, type_data
var storyChars = {
	"bf": [ "story_bf_sheet", "bf", [8, 1], [[0,1,2,3,4], [5,6,7]], 1],
	"gf": [ "story_gf_sheet", "gf", [10, 2], [[17,0,1,2,3,4,5,6,7,8], [9,10,11,12,13,14,15,16]], 1 ],
	"dad": [ "story_dad_sheet", "", [7, 1], [[0,1,2,3,4,5,6]], 1 ],
	"spooky": [ "story_spooky_sheet", "gf", [8, 1], [[0,1,2,3], [4,5,6,7]], 1 ],
	"pico": [ "story_pico_sheet", "", [10, 2], [[0,1,2,3,4,5,6,7,8,9,10,11]], 2 ],
	"mom": [ "story_mom_sheet", "", [5, 1], [[0,1,2,3,4]], 1 ],
	"parents": [ "story_parents_sheet", "", [5, 1], [[0,1,2,3,4]], 1 ],
	"senpai": [ "story_senpai_sheet", "", [5, 1], [[0,1,2,3,4]], 1 ],
}

var selected = 0
var selectedDif = 1
var canMove = true

var selectTimer = -1

var gfCycle = false

onready var difSpriteStart = $DifStuff/DifSprite.position

# Called when the node enters the scene tree for the first time.
func _ready():
	$DifStuff/DifSprite.vframes = len(Main.difficultys)
	
	Conductor.connect("beat_hit", self, "beatHit")
	
	createWeeks()
	updateWeekStuff()

func _process(delta):
	updateButtons(delta)
	
	if (selectTimer >= 0):
		selectTimer += delta
	
	if (selectTimer >= 1):
		startGame()
		selectTimer = -1

func _input(event):
	if (event.is_action_pressed("cancel")):
		$Sounds/CancelStream.play()
		Main.change_scene(Main.MAIN_MENU)
	
	if (!canMove):
		return
	
	var move = int(event.is_action_pressed("down")) - int(event.is_action_pressed("up"))
	
	if (move != 0):
		selected += move
		
		$Sounds/MoveStream.play()
		
		if (selected > len(weeks) - 1):
			selected = 0
		if (selected < 0):
			selected = len(weeks) - 1
		
		updateWeekStuff()
		
	if (event.is_action_pressed("confirm")):
		$Sounds/ConfirmStream.play()
		
		var node = $StoryCharacters/BfCharacter
		var data = storyChars.get(node.character, null)
	
		if (data != null):
			var animArray = data[3][1]
			node.play(animArray, true, data[4])
		
		selectTimer = 0
		canMove = false
	
func createWeeks():
	for week in weeks.keys():
		createButton(week)

func createButton(weekName):
	var weekData = weeks[weekName]
	
	var spritePath = "res://Assets/Sprites/UI/Story/Weeks/"
	var sprite = load(spritePath + weekData[1] + ".png")
	
	var button = BUTTON_SCENE.instance()
	button.get_node("Sprite").texture = sprite
	$Buttons.add_child(button)

func updateButtons(delta):
	var index = 0
	
	var sep = 110
	
	for button in $Buttons.get_children():
		var trueIndex = index - selected
		
		button.position.y = lerp(button.position.y, sep * trueIndex, delta * 10)
		
		if (index != selected):
			button.modulate.a = 0.6
		else:
			button.modulate.a = 1
		
		index += 1
	
	$DifStuff/DifSprite.frame = selectedDif
	$DifStuff/DifSprite.position.y = move_toward($DifStuff/DifSprite.position.y, difSpriteStart.y, delta * 150)
	
	updateDifButtons("left", $DifStuff/LeftButton, -1)
	updateDifButtons("right", $DifStuff/RightButton, 1)

func updateDifButtons(action, buttonNode, move):
	if (!canMove):
		return
	
	if (Input.is_action_pressed(action)):
		buttonNode.scale = Vector2(0.8, 0.8)
	else:
		buttonNode.scale = Vector2(1, 1)
	
	if (Input.is_action_just_pressed(action)):
		changeDif(move)
		
func updateWeekStuff():
	var weekData = getSelectedWeekData()
	
	var trackString = ""
	for track in weekData[0]:
		trackString += track.replace("-", " ").capitalize() + "\n"
	
	$Tracks.text = trackString.to_upper()
	$WeekName.text = weekData[2].to_upper()
	
	loadCharacter(str(weekData[3]), $StoryCharacters/BfCharacter)
	loadCharacter(str(weekData[4]), $StoryCharacters/DadCharacter)
	loadCharacter(str(weekData[5]), $StoryCharacters/GfCharacter)

func changeDif(move):
	selectedDif += move
	
	if (selectedDif > len(Main.difficultys) - 1):
		selectedDif = 0
	if (selectedDif < 0):
		selectedDif = len(Main.difficultys) - 1
	
	$DifStuff/DifSprite.frame = selectedDif
	$DifStuff/DifSprite.position.y = difSpriteStart.y - 10
	
func getSelectedWeekData():
	return weeks[weeks.keys()[selected]]

func startGame():
	var weekData = getSelectedWeekData()
	
	var songName = weekData[0][0]
	var difName = Main.difficultys[selectedDif]
	
	Main.change_playstate(songName, difName, 1, weekData[0])

func loadCharacter(charName, node):
	var charData = storyChars.get(charName, null)
	
	if (charData != null):
		node.visible = true
		
		var spritePath = "res://Assets/Sprites/UI/Story/Characters/"
		var sprite = load(spritePath + charData[0] + ".png")
		
		node.texture = sprite
		
		node.hframes = charData[2][0]
		node.vframes = charData[2][1]
		
		if (node.character != charName):
			node.curFrame = 0
			node.speed = 0
			node.gfState = true
		
		node.character = charName
	else:
		node.visible = false

func beatHit():
	var nodes = [$StoryCharacters/BfCharacter, $StoryCharacters/GfCharacter, $StoryCharacters/DadCharacter]
	
	for node in nodes:
		nodePlay(node)

func nodePlay(node):
	var data = storyChars.get(node.character, null)
	
	node.gfState = !node.gfState
	
	if (data != null):
		var animArray = data[3][0]
		
		if (data[1] == "gf"):
			if (node.gfState):
				animArray = data[3][1]
		
		if (data[1] == "bf"):
			if (selectTimer >= 0):
				return
		
		node.play(animArray, true, data[4])
