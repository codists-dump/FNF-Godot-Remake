extends ChoiceMenu

var infoMode = false
var infoOffset = Vector2(-60, -310)
var curInfoOffset = Vector2(0, 0)
var infoFade = 0

func _process(delta):
	var gotoOffset = Vector2(0, 0)
	var fadeTo = 0.6
	if (infoMode):
		gotoOffset = infoOffset
		fadeTo = 0
	
	curInfoOffset = lerp(curInfoOffset, gotoOffset, 10 * delta)
	infoFade = lerp(infoFade, fadeTo, 10 * delta)

func draw_options():
	var idx = 0
	for option in options:
		var sIdx = idx - selected
		
		var color = Color.white
		if (selected != idx):
			color.a = infoFade
		if (!enabled):
			color = Color.webgray
			
		if (infoMode):
			offset = Vector2(0, 0)
			
		var posNew = (Vector2((sIdx * optionsOffset.x) + 70, (sIdx * optionsOffset.y) + 320) + offset)
		posNew += curInfoOffset
		
		draw_string(FONT, position + posNew, option.to_upper(), color)
		
		if (useIcons):
			if (len(optionIcons) >= idx):
				if (optionIcons[idx] != null):
					var imageSize = Vector2(optionIcons[idx].get_width(), optionIcons[idx].get_height())
					
					var iconSizeTemp = iconSize
					if (iconSizeTemp < Vector2.ZERO):
						iconSizeTemp = imageSize
					
					var srcRect = Rect2(Vector2.ZERO, iconSizeTemp)
					var rect = Rect2(position + posNew + Vector2((option.length()*50) + 20, -30), iconSizeTemp)
					
					if (iconSelectionAnim && selected == idx):
						srcRect.position.x += iconSize.x
					
					draw_texture_rect_region(optionIcons[idx], rect, srcRect, color)
		
		idx += 1
