extends Node2D

var lastSelected = -1

var selectedDifficulty = 2
var selectedSpeed = 1

var difficultys = ["EASY", "NORMAL", "HARD"]

func _ready():
	get_songs()
	
	var songsMenu = $CanvasLayer/ChoiceMenu
	songsMenu.optionOffset.y = 120
	songsMenu.connect("option_selected", self, "song_chosen")

func _process(_delta):
	if (Input.is_action_just_pressed("cancel")):
		$CancelStream.play()
		Main.change_scene(Main.MAIN_MENU)
		
	var move = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
	if (Input.is_key_pressed(KEY_SHIFT)):
		selectedSpeed += move * 0.1
	else:
		selectedDifficulty += move
	
	selectedDifficulty = clamp(selectedDifficulty, 0, difficultys.size()-1)
		
	if ($CanvasLayer/ChoiceMenu.selected != lastSelected):
		song_selected($CanvasLayer/ChoiceMenu.selected)
		
	lastSelected = $CanvasLayer/ChoiceMenu.selected
	
	$CanvasLayer/Label.text = difficultys[selectedDifficulty] + "\n" + str(selectedSpeed) + "x"

func get_songs():
	var songsMenu = $CanvasLayer/ChoiceMenu
	songsMenu.optionOffset.y = 120
	songsMenu.options = []
	
	var dir = Directory.new()
	dir.open("res://Assets/Songs/")
	
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			songsMenu.options.append(file)
			
	songsMenu.options.sort()

func song_selected(option):
	var songName = $CanvasLayer/ChoiceMenu.options[option]
	var json = Conductor.load_song_json(songName)
	
	Conductor.play_song("res://Assets/Songs/" + songName + "/Inst.ogg", json["bpm"])

func song_chosen(option):
	var songName = $CanvasLayer/ChoiceMenu.options[option]
	var difficulty = difficultys[selectedDifficulty].to_lower()
	
	var json = Conductor.load_song_json(songName)
	
	Main.change_playstate(songName, difficulty, selectedSpeed)
