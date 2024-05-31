extends Node

var game: Game
var hud: Hud

# Called when the node enters the scene tree for the first time.
func _ready():
	hud = get_tree().get_first_node_in_group('Hud')
	game = get_tree().get_first_node_in_group('Game')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
