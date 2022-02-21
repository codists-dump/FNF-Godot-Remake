extends Control

func add_note_types(noteTypes):
	for noteType in noteTypes.keys():
		var data = noteTypes[noteType]
		
		var image = data[0].get_data()
		image.crop(data[1].x, data[1].y)
		
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		
		$ItemList.add_icon_item(texture)
