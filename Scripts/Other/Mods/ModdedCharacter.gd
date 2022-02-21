extends Character
class_name ModdedCharacter

func _ready():
	var spr = Sprite.new()
	spr.name = "Sprite"
	add_child(spr)
	
	var animator = AnimationPlayer.new()
	animator.name = "AnimationPlayer"
	add_child(animator)
	
	setup_character()
	setup_sprites()
	
	play("idle")

# animArray = [[pos,frame_num], etc...]
func add_animation(name, animArray):
	if (get_node_or_null("AnimationPlayer") == null):
		return
	
	var anim = Animation.new()
	var track_index = anim.add_track(Animation.TYPE_VALUE)
	
	anim.track_set_path(track_index, "Sprite:frame")
	
	for frame in animArray:	
		var time = frame[0]
		var key = frame[1]
		anim.track_insert_key(track_index, time, key)
	
	$AnimationPlayer.add_animation(name, anim)
	
func add_by_prefix(dir, name, xmlName, offset=[0,0], step=0.05, loops=false):
	if (get_node_or_null("AnimationPlayer") == null):
		return
	
	Mods.add_by_prefix($AnimationPlayer, dir, name, xmlName, offset, step, loops)

func add_sheet(dir, hframes, vframes):
	if (get_node_or_null("Sprite") == null):
		return
	
	$Sprite.texture = Mods.mod_image(dir)
	$Sprite.hframes = hframes
	$Sprite.vframes = vframes
	
func add_sparrow_atlas(dir):
	if (get_node_or_null("Sprite") == null):
		return
	
	Mods.add_sparrow_atlas($Sprite, dir)

func setup_sprites():
	pass
