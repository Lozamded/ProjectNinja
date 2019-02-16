extends KinematicBody2D

var direction = 0

var move_x = 0
var move_y = 0

export var tope = 60
export var constSubida = 450
var subida = 0

var jump = false
var correr = 1
const corrida = 2.25
var colisionador

func _physics_process(delta):
	move_y += 1500 * delta 
		
	move_x = ( int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")) ) * 200 * correr
	
	colisionador = $Area2D.get_overlapping_bodies()
	print("col inf: " + str(colisionador))
		
	if is_on_floor():
		if(move_y != 0):
			#print ("y " + str(move_y))
			#print ("puedo saltar")
			#jump = false
			move_y = 0
			jump = false
		if Input.is_action_just_pressed("ui_jump") and jump == false:
			print ("Salte")
			jump = true
			move_y -= constSubida
	
	if Input.is_action_pressed("ui_run"):
		correr = corrida
	else:
		correr = 1
		
	
	if Input.is_action_pressed("ui_jump"):
		if jump == true:
			#print ("subida " + str(subida))
			if subida < tope:
				subida += constSubida * delta
			else:
				jump = false
				subida = 0

		move_y -= subida
	elif Input.is_action_just_released("ui_jump"):
		jump = false
		subida = 0
		
	move_and_slide(Vector2(move_x,move_y), Vector2(0,-1))