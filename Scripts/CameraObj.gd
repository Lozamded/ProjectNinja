extends Sprite

export (NodePath) var playerPath
var player

func _ready():
	player = get_node(playerPath)
	
func _process(delta):
	visible = false
	position.x = player.position.x
