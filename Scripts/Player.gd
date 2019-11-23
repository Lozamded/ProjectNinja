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
var velocidadsalto = 2.24
var empujesalto = 1
const corrida = 2.45

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

var canrun = true

var canDash = true
var enddash = false
var timerDash
export var dashTime = 0.65
var dash = false
var dashValue = 1
var dashconst = 4.25

var estado = "idle"

export (NodePath) var analogoPath
export (NodePath) var fallcheckerPath

var analogo
var fallchecker

func _ready():
	analogo = get_node(analogoPath)
	fallchecker = get_node(fallcheckerPath)
	
	$AnimaPlayer.active = true
	
	#$SpriteUp.modulate.a = 0
	#$SpriteDown.modulate.a = 0
	
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
	timerDash.connect("timeout",self,"endDash")

func _physics_process(delta):
	
	move_x = 265 * dashValue * empujesalto * move + empuje
	
	#print ("move X: " + str(move_x) + " dir " + str (dir)  + " saltoDir " + str(dirSalto) + " canAttack " + str(canAttack) + " Attack " + str(attack) )
	#print ("Grab "+ str(grab) + " Grab timer: " + str(grabTimer) + " jump " + str(jump) )
	
	
	#colisionador = $ColisionInferior.get_overlapping_bodies()
	#print ("colision " + str(colisionador) + "total " + str(colisionador.size()))
	#print ("move_x: " + str(move_x) + " subida: " + str(subida)  + " damage: " + str(damage) + " canGrab: " + str(canGrab) )
		
	if is_on_floor():
		dir = 1
		#$SpriteUp.flip_h = false
		#$SpriteDown.flip_h = false
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
			#$SpriteUp.animation = "Fall"
			#$SpriteDown.animation = "Fall"
			estado = "dash"
			
		if enddash == true and $AnimaPlayer.get("parameters/shot/active") :
			#$SpriteUp.animation = "Run"
			#$SpriteDown.animation = "Run"
			estado = "run"
			dash = false
			enddash = false
			canDash = true
			
		if dash == false and enddash == false:
			estado = "run"

				
	
	if (Input.is_action_pressed("ui_run")  or analogo.joystick_vector.x < -0.35 ) and is_on_floor() and canDash:
		print ("dash...")
		timerDash.start()
		dash = true
		canDash = false
		
	if dash:
		dashValue = dashconst

	else:
		dashValue = 1

		
	if Input.is_action_just_pressed("ui_attack") and move != 0:
		print ("hacer el dash")
		estado = "enddash"
		
		if(canAttack == true):
			canAttack = false
			#sprite_previo = $SpriteUp.animation
			attack = true
			#$SpriteUp.speed_scale = 0.25
			#$SpriteUp.animation = "Slash"
			
			
			
		
#Saltos
	
	if ( Input.is_action_just_pressed("ui_accept") or (analogo.joystick_active == true and analogo.joystick_vector.y > 0.16 ) ) and jump and dash ==false: 
		saltando = true
		enddash = false
		canDash = true
	
	if ( Input.is_action_pressed("ui_accept") or (analogo.joystick_active == true and analogo.joystick_vector.y > 0.16 ) ) and move != 0 :
		jump = false
		
		if saltando:
			empujesalto = 2.24
			if subida < tope*0.95:
				estado = "jump"
				subida = lerp(subida,tope, 0.2)
			else:
				saltando = false
				dirSalto = dir
				estado = "fall"

		
	elif (Input.is_action_just_released("ui_accept") or analogo.joystick_active == false) and saltando and damage == false:
		saltando = false
		dirSalto = dir
		
	
	if not saltando:
		empujesalto = 1
		subida = lerp(subida,0,0.1)		
		gravity += 1450 * delta
		grabMovement = 1

		

		
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
		empuje += empujeconst
		move = 0
		#$SpriteUp.animation = "Damage"
		#$SpriteDown.animation = "Damage"
		estado = "damage"
		canGrab = false
		
	if position.y > fallchecker.position.y:
		print ("I'm dead")
		get_tree().reload_current_scene()
		
	
	#print ("estado " + estado)
	
	match estado:
		"run":
			$AnimaPlayer.set("parameters/ani1/current",1)
			$AnimaPlayer.set("parameters/speed/scale",3.65)
						
		"jump":
			$AnimaPlayer.set("parameters/ani1/current",2)
			$AnimaPlayer.set("parameters/speed/scale",3.12)
			
		"fall":
			$AnimaPlayer.set("parameters/ani1/current",3)
			$AnimaPlayer.set("parameters/speed/scale",3.65)
			
		"dash":
			$AnimaPlayer.set("parameters/ani1/current",4)
			$AnimaPlayer.set("parameters/speed/scale",3.65)
			
		"enddash":
			$AnimaPlayer.set("parameters/shot/active",true)
			$AnimaPlayer.set("parameters/speed/scale",12.12)
			
			#$AnimaPlayer.get


func setDamage(punchDir):
	jump = true
	saltando = true
	timerDamage.start()
	damage = true
	match punchDir:
		1: 
			empujeconst = 24
		-1:
			empujeconst =  -24
		
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
	
func endDash():
	print ("----------------STOP dash----------------")
	dash = false
	estado = "enddash"
	enddash = true
	#canDash = true
	#canrun = true

	#dash = false
	
func canDashAgain():
	print ("STOP dash")
	estado = "enddash"
	dash = false
	canDash = true
	
	

