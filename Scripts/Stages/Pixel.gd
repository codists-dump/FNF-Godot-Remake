extends "res://Scripts/States/PlayState.gd"

var frameTimer = 0
var frameSpeed = 0.3

var bop = true

var pixelFont = preload("res://Assets/Other/Fonts/font-pixel.tres")

func _ready():
	$HUD/HudElements/TextBar.set("custom_fonts/font", pixelFont)
	$HUD/HudElements/TopBar/TopBarLabel.set("custom_fonts/font", pixelFont)

	RATING_SCENE = preload("res://Scenes/Stages/Other/Pixel/Rating.tscn")

func _process(delta):
	var tree = $Background/ParallaxBackground/ParallaxLayer4/WeebTrees
	frameTimer += delta
	
	if (frameTimer >= frameSpeed):
		tree.frame += 1
		frameTimer = 0
	
	if tree.frame >= (tree.hframes * tree.vframes) - 1:
		tree.frame = 0
	
	print(tree.frame)

func hud_bop():
	.hud_bop()
	
	var anim = $Background/ParallaxBackground/ParallaxLayer3/BgFreaks/AnimationPlayer
	anim.stop()
	
	if (bop):
		anim.play("Down")
	else:
		anim.play("Up")
		
	bop = !bop
