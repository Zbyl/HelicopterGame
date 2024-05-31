extends RigidBody3D

@onready var bazooka_beaver = $".."

func hit(force):
	bazooka_beaver.hit(force)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
