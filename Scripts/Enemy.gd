extends KinematicBody2D

var gravity = 0
var direction = 0
export var velocidad = 224

var move_x = 0
var move_y = 0
var subida = 0

onready var player = get_parent().get_node("Player")
#onready var enemy = get_parent().get_node("Enemys")

var choque = false
var timerChoque
var wallDetector = 1
export var choqueColdown = 4


var dir = 0

func _ready():
	randomize();
	while (dir == 0):
		dir = randi()%1+-1 
	print ("parto en direccion" + str(dir))
	timerChoque = Timer.new()
	add_child(timerChoque)
	timerChoque.set_one_shot(true)
	timerChoque.set_wait_time(choqueColdown)
	timerChoque.connect("timeout",self,"yaChoco")
#	add_collision_exception_with(enemy)
	

func _physics_process(delta):
	
	gravity += 1450 * delta
	move_x = dir * velocidad * wallDetector
	
	match dir:
		-1:
			$Sprite.flip_h = true
		1:
			$Sprite.flip_h = false
			
	if is_on_floor():
		gravity = 0
		
				
			
	var colliders = move_and_slide(Vector2(move_x,gravity-subida), Vector2(0,-1))
	
	if get_slide_count( )>0:
		for i in range(get_slide_count()):
			var col = get_slide_collision(i)
			if col.collider.is_in_group("Walls"):
				wallDetector = 0
				#print ("Enenmigo una muralla")
				match dir:
					1: 
						dir = -1
						move_x -= 425
						wallDetector = 1
					-1:
						dir = 1
						move_x += 425
						wallDetector = 1
			if col.collider.is_in_group("Player"):
				#print("Toque al playaar ")
				player.setDamage(dir)
				
			if col.collider.is_in_group("Enemys"):
				add_collision_exception_with(col.collider)
	

