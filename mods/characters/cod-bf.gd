extends ModdedCharacter

func setup_character():
	camOffset = Vector2(200, -200)
	characterColor = Color(0.84705882352, 0.21176470588, 0.21176470588)
	
	iconSheet = Mods.mod_image(Mods.imageDir + "/icons/icon-codist-bf.png")

func setup_sprites():
	$Sprite.position.y -= 120
	
	var path = Mods.imageDir + "/characters/codist_bf"
	add_sparrow_atlas(path)
	
	var spd = 0.02
	add_by_prefix(path, "idle", "BF idle dance", [0, 0], spd)
	
	add_by_prefix(path, "singLEFT", "BF NOTE LEFT", [-10, 10], spd)
	add_by_prefix(path, "singDOWN", "BF NOTE DOWN", [0, 30], spd)
	add_by_prefix(path, "singUP", "BF NOTE UP", [30, 0], spd)
	add_by_prefix(path, "singRIGHT", "BF NOTE RIGHT", [40, 10], spd)
