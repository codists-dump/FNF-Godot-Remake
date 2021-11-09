extends Node2D

var playState

var subMenuOpen = false

var songsMenu
var selectedDifficulty = 2
var selectedSpeed = 1
var difficultys = ["EASY", "NORMAL", "HARD"]

var options = ["RESUME", "RESTART SONG", "TOGGLE BOTPLAY", "OPTIONS", "CHANGE SONG", "EXIT TO TITLE"]

func _ready():
	var _c_loaded = get_tree().current_scene.connect("scene_loaded", self, "_scene_loaded")
	
	playState = get_tree().current_scene.current_scene
	$CanvasLayer/Options.options = options
	
	var label = $CanvasLayer/Label
	$Tween.interpolate_property(label, "rect_position:y", -100, label.rect_position.y, 1.6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(label, "modulate:a", 0, 1, 1.6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()

func _process(_delta):
	if (get_tree().paused == false):
		queue_free()
		
	if (Input.is_action_just_pressed("cancel")):
		if (subMenuOpen):
			var subMenu = get_node_or_null("CanvasLayer/SubOptions")
			if (subMenu == null):
				subMenuOpen = false
			else:
				$CanvasLayer/Options.enabled = true
				
				subMenu.queue_free()
				songsMenu = null
				subMenuOpen = false
				return
				
		if (!subMenuOpen):
			get_tree().paused = false
	
	if (songsMenu != null):
		var move = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
		if (Input.is_key_pressed(KEY_SHIFT)):
			selectedSpeed += move * 0.1
		else:
			selectedDifficulty += move
		
		selectedDifficulty = clamp(selectedDifficulty, 0, difficultys.size()-1)
		
	pause_text_process()
	

func option_selected(selected):
	match (selected):
		0:
			get_tree().paused = false
		1:
			playState.restart_playstate()
		2:
			Settings.botPlay = !Settings.botPlay
		4:
			create_songs_menu()
		5:
			Main.change_scene("res://Scenes/States/MainMenuState.tscn")
			
func pause_text_process():
	var pauseText = playState.song.capitalize() + "\n" + playState.difficulty.to_upper() + "\n" + str(playState.speed) + "x"
	
	match ($CanvasLayer/Options.selected):
		2:
			pauseText = str(Settings.botPlay).to_upper()
		4:
			if (songsMenu != null):
				pauseText = difficultys[selectedDifficulty] + "\n" + str(selectedSpeed) + "x"
	
	$CanvasLayer/Label.text = pauseText

func _scene_loaded():
	get_tree().paused = false
	
func create_songs_menu():
	$CanvasLayer/Options.enabled = false
	subMenuOpen = true
	
	songsMenu = ChoiceMenu.new()
	songsMenu.position.x += 200
	songsMenu.optionOffset.y = 100
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
	
	songsMenu.name = "SubOptions"
	$CanvasLayer.add_child(songsMenu)
	
	songsMenu.connect("option_selected", self, "song_selected")

func song_selected(selected):
	var song = songsMenu.options[selected]
	var difficulty = difficultys[selectedDifficulty].to_lower()
	Main.change_playstate(song, difficulty, selectedSpeed)
