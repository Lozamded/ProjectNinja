extends KinematicBody2D

var direction = 0

var move_x = 0
var move_y = 0

export var tope = 700
export var coldownDamage = 0.45
export var coldownGrab = 0.12
var subida = 0

var jump = false
var saltando = false
var controlEnSalto = 1
var move = 1
var damage = false
var correr = 1
var dificultadsalto = 1
const corrida = 2.25

var timerDamage
var timerGrab = 0

var colisionador

var gravity = 0
var dir = 1
var dirSalto = 0
var grab = false
var grabMovement = 1
var canGrab = true

var canAttack = true
var attack = false
var sprite_previo = ""
var attackTimer = 12

var empuje = 0
var empujeconst = 265


var canDash = true
var timerDash
export var dashTime = 1.25
var dash = false
var dashValue = 1
var dashconst = 4.25

export (NodePath) var analogoPath
export (NodePath) var fallcheckerPath

var analogo
var fallchecker

func _ready():
	analogo = get_node(analogoPath)
	fallchecker = get_node(fallcheckerPath)
	
	timerDamage = Timer.new()
	add_child(timerDamage)
	timerDamage.set_one_shot(true)
	timerDamage.set_wait_time(coldownDamage)
	timerDamage.connect("timeout",self,"stopDamage")
	
	timerGrab = Timer.new()
	add_child(timerGrab)
	timerGrab.set_one_shot(true)
	timerGrab.set_wait_time(coldownGrab)
	timerGrab.connect("timeout",self,"canGrabAgain")
	
	timerDash = Timer.new()
	add_child(timerDash)
	timerDash.set_one_shot(true)
	timerDash.set_wait_time(dashTime)
	timerDash.connect("timeout",self,"canDashAgain")

func _physics_process(delta):
	
	move_x = 265 * dashValue * dificultadsalto * move + empuje
	
	#print ("move X: " + str(move_x) + " dir " + str (dir)  + " saltoDir " + str(dirSalto) + " canAttack " + str(canAttack) + " Attack " + str(attack) )
	#print ("Grab "+ str(grab) + " Grab timer: " + str(grabTimer) + " jump " + str(jump) )
	
	
	#colisionador = $ColisionInferior.get_overlapping_bodies()
	#print ("colision " + str(colisionador) + "total " + str(colisionador.size()))
	#print ("move_x: " + str(move_x) + " subida: " + str(subida)  + " damage: " + str(damage) + " canGrab: " + str(canGrab) )
		
	if is_on_floor():
		dir = 1
		$SpriteUp.flip_h = false
		$SpriteDown.flip_h = false
		empuje = 0
		dirSalto = 0
		dificultadsalto = 1
		gravity = 0
		jump = true
		subida = 0
		controlEnSalto = 1
		$ColorRect.color = Color8(0,255,0,255)
		#Sprites
		if dash:
			$SpriteUp.animation = "Fall"
			$SpriteDown.animation = "Fall"

		if dash == false : 
			$SpriteUp.animation = "Run"
			$SpriteDown.animation = "Run"

			
	else:
		$ColorRect.color = Color8(255,0,0,255)
		if saltando == false:
			if dirSalto != dir and dirSalto != 0:
				dificultadsalto = 0.45
			else:
				dificultadsalto = 1
				
	
	if (Input.is_action_pressed("ui_run")  or analogo.joystick_vector.x < -0.35 ) and is_on_floor() and canDash:
		print ("dash...")
		timerDash.start()
		dash = true
		canDash = false
		
	if dash:
		dashValue = dashconst
		$SpriteUp.rotation_degrees = -90
		$SpriteDown.rotation_degrees = -90
	else:
		dashValue = 1
		$SpriteUp.rotation_degrees = 0
		$SpriteDown.rotation_degrees = 0
		
	if Input.is_action_just_pressed("ui_attack") and move != 0:
		if(canAttack == true):
			canAttack = false
			sprite_previo = $SpriteUp.animation
			attack = true
			$SpriteUp.speed_scale = 0.25
			$SpriteUp.animation = "Slash"
			
			
			
	if $SpriteUp.animation == "Slash":
		if( $SpriteUp.frame == $SpriteUp.frames.get_frame_count("Slash") -1):
			print("temino el ataque")
			attack = false
	else:
		canAttack = true
		attack = false
		
#Saltos
	
	if ( Input.is_action_just_pressed("ui_accept") or (analogo.joystick_active == true and analogo.joystick_vector.y > 0.25 ) ) and jump and dash ==false: 
		saltando = true
	
	if ( Input.is_action_pressed("ui_accept") or (analogo.joystick_active == true and analogo.joystick_vector.y > 0.25 ) ) and move != 0 :
		jump = false
		
		if grab == true:
			dificultadsalto = 0.25
			match dir:
				1:
					empuje += 81
				-1:
					empuje -= 91
		else:
			empuje = 0
		
		if saltando:
			if subida < tope*0.95:
				if(attack == false):
					$SpriteUp.animation = "Jump"
					$SpriteDown.animation = "Jump"
				else:
					$SpriteDown.animation = "Fall"
				subida = lerp(subida,tope, 0.2)
			else:
				saltando = false
				dirSalto = dir

		
	elif (Input.is_action_just_released("ui_accept") or analogo.joystick_active == false) and saltando and damage == false:
		saltando = false
		dirSalto = dir
	
	if not saltando:
		subida = lerp(subida,0,0.1)
		if not is_on_floor():
			if(attack == false):
				$SpriteUp.animation = "Fall"
			$SpriteDown.animation = "Fall"
			
		if grab == false:
			gravity += 1450 * delta
			grabMovement = 1
		else:
			gravity = 0
			jump = true
			subida = 0
			controlEnSalto = 1
			if(attack == false):
				$SpriteUp.animation = "Hold"
			$SpriteDown.animation = "Hold"
			jump = false
			grabMovement = 0

		
	var colliders = move_and_slide(Vector2(move_x,gravity-subida), Vector2(0,-1))
	
	if get_slide_count( )>0:
		for i in range(get_slide_count()):
			var col = get_slide_collision(i)
			if col.collider.is_in_group("Enemys") and damage == false:
				#print ("Toque un enemigo")
				setDamage(-dir)

	
	if is_on_ceiling():
		saltando = false
		subida = 0
		
	
	if damage:
		subida += 4
		empuje += empujeconst
		move = 0
		$SpriteUp.animation = "Damage"
		$SpriteDown.animation = "Damage"
		canGrab = false
		
	if position.y > fallchecker.position.y:
		print ("I'm dead")
		get_tree().reload_current_scene()
		

func setDamage(punchDir):
	jump = true
	saltando = true
	timerDamage.start()
	damage = true
	match punchDir:
		1: 
			empujeconst = 12
		-1:
			empujeconst =  -12
		
func stopDamage():
	empuje = 0
	move = 1
	damage = false
	saltando = false
	jump = false
	timerGrab.start()
	print("termino el daño")
	
func canGrabAgain():
	canGrab = true
	
func canDashAgain():
	print ("STOP dash")
	subida += 4
	dash = false
	canDash = true
