extends Node2D

var vsp = -180
var gravity = 450

var combo = 0
var offset = 0

var numberVsps = []

export var numberTexture = preload("res://Assets/Sprites/UI/combo.png")

func _ready():
	create_numbers()
	
	$Sprite/Label.text = str(round(offset)) + "ms"

func _process(delta):
	$Sprite.position.y += vsp * delta
	vsp += gravity * delta
	
	if (vsp > 0):
		modulate.a -= 3 * delta
		
	if (modulate.a <= 0):
		queue_free()
	
	move_numbers(delta)
	
func move_numbers(delta):
	var index = 0
	for child in get_children():
		if (index == 0):
			index += 1
			continue
		
		child.position += numberVsps[index-1] * delta
		numberVsps[index-1].y += gravity * delta
		
		index += 1

func create_numbers():
	var comboLen = len(str(combo))
	var trueLength = comboLen
	
	var sep = -40
	if (Settings.hudRatings):
		sep = -60
	
	if (comboLen < 3 && combo >= 0):
		comboLen = 3
	for i in range(comboLen):
		var pos = Vector2(sep * i, 0)
		var number = str(combo).substr(trueLength-(i+1), 1)
		create_number(pos, number)

func create_number(pos, number):
	var num = Sprite.new()
	num.texture = numberTexture
	
	var scl = Vector2(0.5, 0.5)
	var off = Vector2(-50, 60)
	if (Settings.hudRatings):
		scl = Vector2(0.7, 0.7)
		off = Vector2(-70, 100)
		
	num.scale = scl
	num.position = pos + off
	
	num.hframes = 11
	num.vframes = 2
	if (number == "-"):
		num.frame = 0
	else:
		num.frame = int(number)+1
		
	if (combo < 0):
		num.modulate = Color("db4d4d")
	
	numberVsps.append(Vector2(0, rand_range(-170, -200)))
	
	add_child(num)
