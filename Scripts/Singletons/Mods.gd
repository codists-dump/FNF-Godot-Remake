extends Node

var modsFolder = OS.get_executable_path().get_base_dir() + "/mods/"
var songsDir
var charactersDir
var imagesDir
var scriptsDir

func _ready():
	if !(OS.has_feature("standalone")):
		modsFolder = "res://.mods/"
		
	songsDir = modsFolder + "/songs/"
	charactersDir = modsFolder + "/characters/"
	imagesDir = modsFolder + "/images/"
	scriptsDir = modsFolder + "/scripts/"
		
	var dir = Directory.new()
	
	# add a mods folder
	if (!dir.dir_exists(modsFolder)):
		dir.make_dir(modsFolder)
	
	# load the stuff
	load_characters()

func load_characters():
	var dir = Directory.new()
	
	if (dir.dir_exists(charactersDir)):
		dir.open(charactersDir)
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		while (file_name != ""):
			if (!dir.current_is_dir()):
				var charName = file_name.trim_suffix(".gd")
				
				print("Loading character: " + charName)
				Main.CHARACTERS[charName] = load(charactersDir + "/" + file_name)
			
			file_name = dir.get_next()
			
# load files

# add check for .imports
func mod_image(dir):
	if (check_if_native(dir)):
		return load(dir)
	else:
		var image = Image.new();
		image.load(dir)
		
		var texture = ImageTexture.new()
		texture.create_from_image(image)

		return texture

func mod_ogg(dir):
	if (check_if_native(dir)):
		return load(dir)
	else:
		var songFile = File.new();
		
		songFile.open(dir, File.READ);
		var b = songFile.get_buffer(songFile.get_len())
		var d = AudioStreamOGGVorbis.new();

		d.data = b
		return d

func mod_script(dir):
	if (check_if_native(dir)):
		return load(dir)
	else:
		var scriptFile = File.new();
		if (scriptFile.file_exists(dir)):
			return load(dir)
		else:
			return 0

func check_if_native(dir):
	return (dir.begins_with("res://") && OS.has_feature("standalone"))

# sparrow atlas shit
func add_sparrow_atlas(spriteNode, dir):
	spriteNode.texture = mod_image(dir + ".png")
	spriteNode.hframes = 1
	spriteNode.vframes = 1
	spriteNode.frame = 0

	spriteNode.region_enabled = true
	spriteNode.centered = false

func add_by_prefix(animationPlayer, dir, name, xmlName, offset=[0,0], step=0.05, loops=false):
	var anim = Animation.new()
	var box_track = anim.add_track(Animation.TYPE_VALUE)
	var offset_track = anim.add_track(Animation.TYPE_VALUE)
	
	anim.value_track_set_update_mode(box_track, Animation.UPDATE_DISCRETE)
	anim.track_set_path(box_track, "Sprite:region_rect")
	
	anim.value_track_set_update_mode(offset_track, Animation.UPDATE_DISCRETE)
	anim.track_set_path(offset_track, "Sprite:offset")
	
	var parser = XMLParser.new()

	print(dir + ".xml")

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
				if (fx == null):
					fx = 0
				if (fy == null):
					fy = 0
				if (fw == null):
					fw = w
				if (fh == null):
					fh = h
				
				anim.track_insert_key(box_track, time, Rect2(x, y, w, h))
				anim.track_insert_key(offset_track, time, -Vector2(fx, fy) + Vector2(offset[0], offset[1]))
				time += step
	
	anim.loop = loops
	anim.length = time
	animationPlayer.add_animation(name, anim)
