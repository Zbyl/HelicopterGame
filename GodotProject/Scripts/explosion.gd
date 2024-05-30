extends Node3D

class_name Explosion

@onready var explosion_sound = $ExplosionSound
@onready var sparks = $Sparks
@onready var flash = $Flash
@onready var fire = $Fire
@onready var smoke = $Smoke


# Called when the node enters the scene tree for the first time.
func _ready():
	explode()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func explode():
	explosion_sound.play()
	sparks.emitting = true
	flash.emitting = true
	fire.emitting = true
	smoke.emitting = true
	await get_tree().create_timer(2.8).timeout
	queue_free()
