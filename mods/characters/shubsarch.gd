extends ModdedCharacter

func setup_character():
	flipX = true
	camOffset = Vector2(-200, -200)
	characterColor = Color(0.84705882352, 0.21176470588, 0.21176470588)
	
	iconSheet = Mods.mod_image(Mods.imageDir + "/icons/icon-shubsa.png")

func setup_sprites():
	$Sprite.position.y -= 220
	
	var path = Mods.imageDir + "/characters/ShubsArch"
	add_sparrow_atlas(path)
	
	add_by_prefix(path, "idle", "Shubs")
	
	add_by_prefix(path, "singLEFT", "Shubs")
	add_by_prefix(path, "singDOWN", "Shubs")
	add_by_prefix(path, "singUP", "Shubs")
	add_by_prefix(path, "singRIGHT", "Shubs")
