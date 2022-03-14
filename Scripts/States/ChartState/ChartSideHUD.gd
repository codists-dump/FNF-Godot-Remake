extends Control

onready var chartState = $"../../"
var denyInput = false

var dialog

func _process(delta):
	if (denyInput):
		chartState.allowInput = false

func setup_values():
	# File Editor
	$TabContainer/File/SongNameEdit.text = chartState.song
	
	var idx = 0
	for dif in Main.difficultys:
		$TabContainer/File/DifButton.add_item(dif.capitalize())
		if (dif == chartState.dif):
			$TabContainer/File/DifButton.select(idx)
		
		idx += 1
	
	# Chart
	$TabContainer/Chart/VBoxContainer/BPMBox.value = chartState.songData["bpm"]
	
	# Script
	if (chartState.songScript != null):
		$TabContainer/Script/ScriptTextEdit.text = chartState.songScript.get_script().source_code
	else:
		$TabContainer/Script.queue_free()

func save_chart(path):
	print("Saving to " + path)
	
	var data = {"song": chartState.songData}
	var content = JSON.print(data)
	
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(content)
	file.close()

func load_chart(path):
	var truePath = ""
	
	var pathStripped = path.rsplit("/", false, 1)
	truePath = pathStripped[0]
	
	var song = pathStripped[1].trim_suffix(".json")
	var difExt = ""
	var difNum = 1
	
	if (song.ends_with("-easy")):
		difExt = "-easy"
		difNum = 0
	if (song.ends_with("-hard")):
		difExt = "-hard"
		difNum = 2
	
	if (difExt != ""):
		song = song.trim_suffix(difExt)
	
	print(truePath)
	print(song)
	print(difExt)
	
	Conductor.songData = Conductor.load_song_json(song, difExt, truePath)
	Main.change_chart_state(song, difNum)

func new_chart(song="bopeebo"):
	Conductor.songData = null
	Conductor.songName = null
	Conductor.songDifficulty = null
	
	Main.change_chart_state()

func save_script(path):
	path += "script.gd"
	print("Saving to " + path)
	
	var content = $TabContainer/Script/ScriptTextEdit.text
	
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(content)
	file.close()

func get_file_name(addDifExt=true):
	var ext = ""
	
	if (addDifExt):
		ext = "-" + chartState.dif.to_lower()
		if (chartState.dif.to_lower() == "normal"):
			ext = ""
	
	return chartState.song + ext
	
func create_directory_popup():
	dialog = FileDialog.new()
	dialog.theme = theme
	chartState.get_node("HUD").add_child(dialog)
	
	dialog.connect("about_to_show", self, "deny_input")
	dialog.connect("popup_hide", self, "hide_popup")
	
	return dialog
	
func deny_input():
	denyInput = true

func allow_input():
	denyInput = false
	chartState.allowInput = true
	
	if (get_focus_owner() != null):
		get_focus_owner().release_focus()

func hide_popup():
	dialog.queue_free()
	allow_input()

# File Editor
func _on_ChartSideHUD_mouse_entered():
	chartState.allowInput = false

func _on_ChartSideHUD_mouse_exited():
	chartState.allowInput = true
	
	if (get_focus_owner() != null):
		get_focus_owner().release_focus()

func _on_SaveButton_pressed():
	var path = Mods.songsDir + chartState.song + "/" + get_file_name() + ".json"
	save_chart(path)

func _on_LoadButton_pressed():
	create_directory_popup()
	
	dialog.mode = dialog.MODE_OPEN_FILE
	dialog.access = dialog.ACCESS_FILESYSTEM
	dialog.current_dir = Mods.modsFolder
	dialog.set_filters(PoolStringArray(["*.json ; FNF Chart"]))
	dialog.connect("file_selected", self, "load_chart")
	
	dialog.popup_centered(Vector2(400, 400))

func _on_SongNameEdit_text_changed(new_text):
	chartState.song = new_text

func _on_DifButton_item_selected(index):
	var text = $TabContainer/File/DifButton.get_item_text(index)
	chartState.dif = text

func _on_SaveAsButton_pressed():
	create_directory_popup()
	
	dialog.mode = dialog.MODE_SAVE_FILE
	dialog.access = dialog.ACCESS_FILESYSTEM
	dialog.current_dir = Mods.modsFolder
	dialog.current_file = get_file_name()
	dialog.set_filters(PoolStringArray(["*.json ; FNF Chart"]))
	dialog.connect("file_selected", self, "save_chart")
	
	dialog.popup_centered(Vector2(400, 400))

func _on_NewButton_pressed():
	new_chart()

# Section
func _on_SwapSection_pressed():
	chartState.swap_section()

# Chart
func _on_BPMBox_value_changed(value):
	chartState.songData["bpm"] = value
	chartState.change_bpm()
