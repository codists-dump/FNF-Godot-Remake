extends "res://Scripts/Other/Mobile/MobileOnly.gd"

export (bool) var showArrowKeys = true
export (bool) var showConfirmKey = true
export (bool) var showCancelKey = true

func _ready():
	if (!showArrowKeys):
		$Arrows.visible = false
	if (!showConfirmKey):
		$Confirm.visible = false
	if (!showCancelKey):
		$Cancel.visible = false
