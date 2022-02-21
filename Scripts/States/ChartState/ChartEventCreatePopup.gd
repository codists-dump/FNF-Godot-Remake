extends Popup

var events = {
	"Play Animation": ["play_animation", Color.blue, "ARGUMENT 1 = Character\nARGUMENT 2 = Animation Name\n(0 = BF, 1 = ENEMY, 2 = GF)\n\nPlays a animation on the chosen character."],
	"Change Character": ["change_character", Color.darkcyan, "ARGUMENT 1 = Character\nARGUMENT 2 = Character Name\n(0 = BF, 1 = ENEMY, 2 = GF)\n\nChanges the chosen character to another."],
	"Set Camera Zoom": ["zoom_camera", Color.darkslategray, "ARGUMENT 1 = Zoom\nARGUMENT 2 = Speed (optional)\n\nSmoothly zoom the camera to the desired zoom value."],
	"BLAMMED LIGHTS !!": ["no", Color.red, "I wont add balmmed lights."],
}

var step = 0

onready var chartState = $"../../"

signal event_created(step, eventName, eventColor)

func add_events():
	for event in events:
		$ExistingEvents.add_item(event)
		
	if (chartState.songScript != null):
		var scriptEvents = chartState.songScript.get("events")
		if (scriptEvents != null):
			for event in scriptEvents.keys():
				$OtherEvents.add_item(event)
				events[event] = scriptEvents[event]

func selected_event(event):
	print(event)
	
	var eventData = events[event]
	
	$NameEdit.text = eventData[0]
	$ColorEdit.color = eventData[1]
	$Description.text = eventData[2]

func _on_CreateButton_pressed():
	var eventName = $NameEdit.text
	var eventColor = $ColorEdit.color
	var eventArgs = $ArgumentEdit.text
	
	if (eventName == ""):
		return
	
	emit_signal("event_created", step, eventName, eventColor, eventArgs)
	
	visible = false

func _on_ExistingEvents_item_activated(index):
	$OtherEvents.unselect_all()
	selected_event($ExistingEvents.get_item_text(index))

func _on_OtherEvents_item_activated(index):
	$ExistingEvents.unselect_all()
	selected_event($OtherEvents.get_item_text(index))

func _on_CreateEventPopup_about_to_show():
	chartState.allowInput = false

func _on_CreateEventPopup_popup_hide():
	chartState.allowInput = true
