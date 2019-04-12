extends KinematicBody2D

var gravity = 0
var direction = 0
export var velocidad = 120

var move_x = 0
var move_y = 0
var subida = 0

var choque = false
var timerChoque
export var choqueColdown = 0.25


var dir = rand_range(-1,1)

func _ready():
	timerChoque = Timer.new()
	add_child(timerChoque)
	timerChoque.set_one_shot(true)
	timerChoque.set_wait_time(choqueColdown)
	timerChoque.connect("timeout",self,"yaChoco")
	

func _physics_process(delta):
	
	gravity += 1450 * delta
	move_x = dir * velocidad
	
	match dir:
		-1:
			$Sprite.flip_h = false
		1:
			$Sprite.flip_h = true
			
	if is_on_floor():
		gravity = 0
		
	if is_on_wall():
		if(choque == false):
			match dir:
				-1:
					dir = 1
					choque = true
					timerChoque.start()
				1:
					dir = -1
					choque = true
					timerChoque.start()
			
	var colliders = move_and_slide(Vector2(move_x,gravity-subida), Vector2(0,-1))
	
func yaChoco():
	choque == false
