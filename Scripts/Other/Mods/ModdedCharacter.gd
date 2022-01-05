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
	
func add_by_prefix(dir, name, xmlName, offset=[0,0], step=0.05):
	if (get_node_or_null("AnimationPlayer") == null):
		return
	
	var anim = Animation.new()
	var box_track = anim.add_track(Animation.TYPE_VALUE)
	var offset_track = anim.add_track(Animation.TYPE_VALUE)
	
	anim.value_track_set_update_mode(box_track, Animation.UPDATE_DISCRETE)
	anim.track_set_path(box_track, "Sprite:region_rect")
	
	anim.value_track_set_update_mode(offset_track, Animation.UPDATE_DISCRETE)
	anim.track_set_path(offset_track, "Sprite:offset")
	anim.track_insert_key(offset_track, 0, Vector2(offset[0], offset[1]))
	
	var parser = XMLParser.new()

	var errorCode = parser.open(dir + ".xml")
	if errorCode != OK:
		return
	
	var time = 0
	while parser.read() != ERR_FILE_EOF:
		if parser.get_attribute_count() > 0:
			var nName
			var x
			var y
			var w
			var h
			var fx
			var fy
			var fw
			var fh
			for i in range(parser.get_attribute_count()):
				match (parser.get_attribute_name(i)):
					"name":
						if (!parser.get_attribute_value(i).begins_with(xmlName)):
							continue
						nName = parser.get_attribute_value(i)
					"x":
						x = int(parser.get_attribute_value(i))
					"y":
						y = int(parser.get_attribute_value(i))
					"width":
						w = int(parser.get_attribute_value(i))
					"height":
						h = int(parser.get_attribute_value(i))
					"frameX":
						fx = int(parser.get_attribute_value(i))
					"frameY":
						fy = int(parser.get_attribute_value(i))
					"frameWidth":
						fw = int(parser.get_attribute_value(i))
					"frameHeight":
						fh = int(parser.get_attribute_value(i))
			
			var canAdd = true
			if (nName == null):
				canAdd = false
			
			if (canAdd):
				anim.track_insert_key(box_track, time, Rect2(x, y, w, h))
				time += step
	
	$AnimationPlayer.add_animation(name, anim)

func add_sheet(dir, hframes, vframes):
	if (get_node_or_null("Sprite") == null):
		return
	
	$Sprite.texture = Mods.mod_image(dir)
	$Sprite.hframes = hframes
	$Sprite.vframes = vframes
	
func add_sparrow_atlas(dir):
	if (get_node_or_null("Sprite") == null):
		return
	
	$Sprite.texture = Mods.mod_image(dir + ".png")
	$Sprite.hframes = 1
	$Sprite.vframes = 1
	$Sprite.frame = 0
	
	$Sprite.region_enabled = true

func setup_sprites():
	pass
