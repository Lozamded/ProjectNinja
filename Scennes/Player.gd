extends KinematicBody2D

var direction = 0

var move_x = 0
var move_y = 0

export var tope = 700
var subida = 0

var jump = false
var saltando = false
var controlEnSalto = 1
var correr = 1
var dificultadsalto = 1
const corrida = 2.25
var colisionador
var gravity = 0
var dir = 1
var dirSalto = 0

func _physics_process(delta):
	
	move_x = ( int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")) ) * 200 * correr * dificultadsalto
	
	print ("move X: " + str(move_x) + " dir " + str (dir)  + " saltoDir " + str(dirSalto))
	
	if Input.is_action_pressed("ui_right"):
		dir = 1
		$Sprite.flip_h = false
		
	if Input.is_action_pressed("ui_left") :
		dir = -1
		$Sprite.flip_h = true
	
	
	
	colisionador = $Area2D.get_overlapping_bodies()
		
	if is_on_floor():
		dirSalto = 0
		dificultadsalto = 1
		gravity = 0
		jump = true
		subida = 0
		controlEnSalto = 1
		$ColorRect.color = Color8(0,255,0,255)
	else:
		$ColorRect.color = Color8(255,0,0,255)
		if dirSalto != dir and dirSalto != 0:
			dificultadsalto = 0.45
		else:
			dificultadsalto = 1
	
	if Input.is_action_pressed("ui_run"):
		correr = corrida
	else:
		correr = 1
	
	if Input.is_action_just_pressed("ui_accept") and jump:
		dirSalto = dir
		saltando = true
	
	if Input.is_action_pressed("ui_accept"):
		jump = false
		if saltando:
			if subida < tope*0.95:
				subida = lerp(subida,tope, 0.2)
			else:
				saltando = false

		
	elif Input.is_action_just_released("ui_accept") and saltando:
		saltando = false
	
	if not saltando:
		subida = lerp(subida,0,0.1)
		gravity += 1625 * delta 
		
	var choca = move_and_slide(Vector2(move_x,gravity-subida), Vector2(0,-1))
	
	if not choca.y and saltando:
		saltando = false
		subida = 0