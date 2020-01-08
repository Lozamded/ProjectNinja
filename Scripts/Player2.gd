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
var estadoPrevio = "iddle" 

export (NodePath) var analogoPath
export (NodePath) var fallcheckerPath

var playback = AnimationNodeStateMachinePlayback

var analogo
var fallchecker

func _ready():
	analogo = get_node(analogoPath)
	fallchecker = get_node(fallcheckerPath)
	
	
	playback = $AnimaPlayer.get("parameters/playback")
	print ( playback)
	#playback.active = true
	
	playback.start("run")
	
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
	print("---ESTADO: "+ estado+ " ---")
	
	#colisionador = $ColisionInferior.get_overlapping_bodies()
	#print ("colision " + str(colisionador) + "total " + str(colisionador.size()))
	#print ("move_x: " + str(move_x) + " subida: " + str(subida)  + " damage: " + str(damage) + " canGrab: " + str(canGrab) )
		
	if is_on_floor():
		if (estado == "fall" or estado  == "jump"):
			estado = "run"
			playback.start("jump-salida")
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
		#$ColorRect.color = Color8(0,255,0,255)
		
	else:
		if (estado != "jump" and estado != "dash"):
			estado = "fall"
			playback.start("jump-caida")

				
	
	if (Input.is_action_pressed("ui_run")  or analogo.joystick_vector.x < -0.35 ) and is_on_floor() and canDash:
		print ("dash...")
		timerDash.start()
		dash = true
		canDash = false
		playback.start("deslizar-entrada")
		estadoPrevio = estado
		estado = "dash"
		
	if dash:
		dashValue = dashconst
	else:
		dashValue = 1
			
			
			
		
#Saltos
	
	if ( Input.is_action_just_pressed("ui_accept") or (analogo.joystick_active == true and analogo.joystick_vector.y > 0.22) ) and jump and dash ==false:
		playback.start("jump-entrada") 
		saltando = true
		enddash = false
		canDash = true
	
	if ( Input.is_action_pressed("ui_accept") or (analogo.joystick_active == true and analogo.joystick_vector.y > 0.22) ) and move != 0 :
		jump = false
		
		if saltando:
			empujesalto = 2.45
			if subida < tope*0.95:
				estado = "jump"
				subida = lerp(subida,tope, 0.2)
			else:
				playback.start("jump-caida")
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
		playback.start("jump-salida")
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
	canDash = true #Evaluar para despues limitar tiempo entre dash
	estado = "enddash"
	enddash = true
	playback.start("deslizar-salida")
	#canDash = true
	#canrun = true

	#dash = false
	
func canDashAgain():
	print ("STOP dash")
	estado = estadoPrevio
	dash = false
	canDash = true
	
	

