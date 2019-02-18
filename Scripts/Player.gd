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
var grab = false
var grabMovement = 1

func _physics_process(delta):
	
	move_x = ( int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")) ) * 200 * correr * dificultadsalto 
	
	print ("move X: " + str(move_x) + " dir " + str (dir)  + " saltoDir " + str(dirSalto))
	
	if Input.is_action_pressed("ui_right") and grab == false:
		dir = 1
		$Sprite.flip_h = false
		
	if Input.is_action_pressed("ui_left") and grab == false :
		dir = -1
		$Sprite.flip_h = true
	
	
	
	colisionador = $Area2D.get_overlapping_bodies()
	#print ("colision " + str(colisionador) + "total " + str(colisionador.size()))
		
	if is_on_floor():
		dirSalto = 0
		dificultadsalto = 1
		gravity = 0
		jump = true
		subida = 0
		controlEnSalto = 1
		$ColorRect.color = Color8(0,255,0,255)
		#Sprites
		if(move_x == 0):
			$Sprite.animation = "Idle"
		elif saltando == false:
			$Sprite.animation = "Run"
			
	else:
		$ColorRect.color = Color8(255,0,0,255)
		if saltando == false:
			if dirSalto != dir and dirSalto != 0:
				dificultadsalto = 0.45
			else:
				dificultadsalto = 1
				
	
	if colisionador.size() > 1 and not is_on_floor():
		for col in colisionador:
			if col.is_in_group("grab"):
				#print ("es un escalable")
				grab = true
				jump = true
				#print("Grab dir " + str(col.dir))
				match col.dir:
					1:
						$Sprite.flip_h = false
						dir = 1
					-1:
						$Sprite.flip_h = true
						dir = -1
	else:
		grab = false
		
		


	
	if Input.is_action_pressed("ui_run"):
		correr = corrida
		$Sprite.speed_scale = 2.65
	else:
		correr = 1
		$Sprite.speed_scale = 2.12
	
	if Input.is_action_just_pressed("ui_accept") and jump:
		saltando = true
	
	if Input.is_action_pressed("ui_accept"):
		jump = false
		
		if grab == true:
			dificultadsalto = 0.85
			match dir:
				1:
					move_x += 615
				-1:
					move_x -= 615
		
		if saltando:
			if subida < tope*0.95:
				$Sprite.animation = "Jump"
				subida = lerp(subida,tope, 0.2)
			else:
				saltando = false
				dirSalto = dir

		
	elif Input.is_action_just_released("ui_accept") and saltando:
		saltando = false
		dirSalto = dir
	
	if not saltando:
		subida = lerp(subida,0,0.1)
		if not is_on_floor():
			$Sprite.animation = "Fall"
			
		if grab == false:
			gravity += 1625 * delta
			grabMovement = 1
		else:
			gravity = 0
			jump = true
			subida = 0
			controlEnSalto = 1
			$Sprite.animation = "Hold"
			jump = false
			grabMovement = 0


		
		
	var choca = move_and_slide(Vector2(move_x,gravity-subida), Vector2(0,-1))
	
	if not choca.y and saltando:
		saltando = false
		subida = 0