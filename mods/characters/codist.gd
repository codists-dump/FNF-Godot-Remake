extends ModdedCharacter

var idle_frames = [[0, 0], [0.1, 1], [0.2, 2]]

var left_frames = [[0, 5], [0.1, 6]]
var down_frames = [[0, 3], [0.1, 4]]
var up_frames = [[0, 9], [0.1, 10]]
var right_frames = [[0, 7], [0.1, 8]]

func setup_character():
	flipX = true
	camOffset = Vector2(-200, -200)
	characterColor = Color(0.84705882352, 0.21176470588, 0.21176470588)
	
	iconSheet = Mods.mod_image(Mods.imageDir + "/icons/icon-codist.png")

func setup_sprites():
	$Sprite.position.y -= 150
	
	add_sheet(Mods.imageDir + "/characters/codist_sheet.png", 6, 2)
	
	add_animation("idle", idle_frames)
	
	add_animation("singLEFT", left_frames)
	add_animation("singDOWN", down_frames)
	add_animation("singUP", up_frames)
	add_animation("singRIGHT", right_frames)
