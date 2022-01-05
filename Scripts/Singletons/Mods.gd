extends Node

var modsFolder = OS.get_executable_path().get_base_dir() + "/mods"
var songsDir
var charactersDir
var imageDir

func _ready():
	if !(OS.has_feature("standalone")):
		modsFolder = "res://mods"
		
	songsDir = modsFolder + "/songs"
	charactersDir = modsFolder + "/characters"
	imageDir = modsFolder + "/images"
		
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
				var charName = file_name.rstrip(".gd")
				
				print("Loading character: " + charName)
				Main.CHARACTERS[charName] = load(charactersDir + "/" + file_name)
			
			file_name = dir.get_next()
			
# load files

func mod_image(dir):
	var image = Image.new();
	image.load(dir)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)

	return texture

func mod_ogg(dir):
	var songFile = File.new();
	
	songFile.open(dir, File.READ);
	var b = songFile.get_buffer(songFile.get_len())
	var d = AudioStreamOGGVorbis.new();

	d.data = b
	return d
