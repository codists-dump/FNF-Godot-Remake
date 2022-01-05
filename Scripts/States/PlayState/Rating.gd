extends Node2D

var vsp = -200
var gravity = 1000

var combo = 0

var numberTexture = preload("res://Assets/Sprites/UI/combo.png")

func _ready():
	create_numbers()

func _process(delta):
	position.y += vsp * delta
	vsp += gravity * delta
	
	if (vsp > 0):
		modulate.a -= 5 * delta
		
	if (modulate.a <= 0):
		queue_free()

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
	
	add_child(num)
