extends Node3D

class_name Explosion

@onready var explosion_sound = $ExplosionSound

# Called when the node enters the scene tree for the first time.
func _ready():
	explode()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func explode():
	explosion_sound.play()
	await get_tree().create_timer(2.8).timeout
	queue_free()
