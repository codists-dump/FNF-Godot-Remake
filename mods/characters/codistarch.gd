extends ModdedCharacter

func setup_character():
	camOffset = Vector2(200, -200)
	characterColor = Color(0.84705882352, 0.21176470588, 0.21176470588)
	
	iconSheet = Mods.mod_image(Mods.imageDir + "/icons/icon-codista.png")

func setup_sprites():
	$Sprite.position.y -= 200
	
	var path = Mods.imageDir + "/characters/CodistArch"
	add_sparrow_atlas(path)
	
	add_by_prefix(path, "idle", "Idle")
	
	add_by_prefix(path, "singLEFT", "Left", [-60, -10])
	add_by_prefix(path, "singDOWN", "Down", [-30, 90])
	add_by_prefix(path, "singUP", "Up", [10, -30])
	add_by_prefix(path, "singRIGHT", "Right", [140, 5])
