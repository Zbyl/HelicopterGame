extends Node3D

class_name Crate

@export var health: float = 100
const BIG_EXPLOSION = preload("res://Scenes/big_explosion.tscn")
const DEBRIS = preload("res://Scenes/crate_debris.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hit(force: float):
	health -= force
	if health < 0:
		var debris = DEBRIS.instantiate()
		get_tree().root.add_child(debris)
		debris.global_position = global_position

		var explosion = BIG_EXPLOSION.instantiate()
		get_tree().root.add_child(explosion)
		explosion.global_position = self.global_position
		explosion.global_rotation = self.global_rotation
		queue_free()

