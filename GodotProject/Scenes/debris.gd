extends Node3D
@onready var debris_1 = $Debris1
@onready var debris_2 = $Debris2
@onready var debris_3 = $Debris3
@onready var debris_4 = $Debris4

@export var LIFETIME = 5000

@onready var initiated_on = Time.get_ticks_msec()

var rng = RandomNumberGenerator.new()

func rnd():
	return rng.randf_range(-3, 3)

func rVector(x, y, z):
	return Vector3(x*rnd(), y*rnd(), z*rnd())

# Called when the node enters the scene tree for the first time.
func _ready():
	debris_1.apply_impulse(rVector(1, 6, 0), rVector(0.03, 0.03, 0))
	debris_2.apply_impulse(rVector(1, 9, 1), rVector(0, 0.1, 0.5))
	debris_3.apply_impulse(rVector(-0.4, 12, -2), rVector(0.4, 0, 0.7))
	debris_4.apply_impulse(rVector(1, 5, -1), rVector(0, 0, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var now = Time.get_ticks_msec()
	if now > initiated_on + LIFETIME:
		queue_free()
