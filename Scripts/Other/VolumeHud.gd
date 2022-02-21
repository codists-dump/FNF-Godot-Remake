extends CanvasLayer

func _ready():
	$VolumeBar.visible = false
	
func update_volume():
	show()
	update_bars()
	
	$VolumeStream.play()
	$Timer.start(1)
		
func update_bars():
	for bar in $VolumeBar/Bar.get_children():
		if (int(bar.name) < Main.audioLevel + 1):
			bar.modulate.a = 0.5
		else:
			bar.modulate.a = 1

func show():
	$Tween.stop_all()
	
	$VolumeBar.visible = true
	$VolumeBar.rect_position = Vector2(0, 0)

func hide():
	var tween = $Tween
	tween.interpolate_property($VolumeBar, "rect_position",
		Vector2(0, 0), Vector2(0, -100), 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_Tween_tween_completed(_object, _key):
	$VolumeBar.visible = false

func _on_Timer_timeout():
	hide()
