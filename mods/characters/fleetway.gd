extends ModdedCharacter

func setup_character():
	flipX = true
	camOffset = Vector2(-200, -500)
	characterColor = Color(0.84705882352, 0.21176470588, 0.21176470588)
	
	iconSheet = Mods.mod_image(Mods.imageDir + "/icons/icon-fleetway.png")

func setup_sprites():
	$Sprite.position.y -= 450
	
	var path = Mods.imageDir + "/characters/fleetway1"
	add_sparrow_atlas(path)
	
	add_by_prefix(path, "idle", "Fleetway Idle")
	
	add_by_prefix(path, "singLEFT", "Fleetway Left")
	add_by_prefix(path, "singDOWN", "Fleetway Down")
	add_by_prefix(path, "singUP", "Fleetway Up")
	add_by_prefix(path, "singRIGHT", "Fleetway Right")
