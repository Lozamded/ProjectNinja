extends Sprite

export (NodePath) var playerPath

export var lado = 0
var player

func _ready():
	player = get_node(playerPath)
	
func _process(delta):
	visible = false
	position.x = player.position.x  + lado
	
