extends Node3D
@onready var debris_1 = $Debris1
@onready var debris_2 = $Debris2
@onready var debris_3 = $Debris3
@onready var debris_4 = $Debris4

var alpha_tween: Tween

@export var LIFETIME: float = 5.0 # Lifetime in seconds.
@export var FADETIME: float = 1.0 # Fade out time in seconds (within LIFETIME).

@onready var initiated_on = Time.get_ticks_msec()

var rng = RandomNumberGenerator.new()

func rnd():
	return rng.randf_range(-3, 3)

func rVector(x, y, z):
	return Vector3(x*rnd(), rng.randf_range(3, 10), z*rnd())

# Called when the node enters the scene tree for the first time.
func _ready():
	debris_1.apply_impulse(rVector(1, 6, 0), rVector(0.03, 0.03, 0))
	debris_2.apply_impulse(rVector(1, 9, 1), rVector(0, 1, 0.5))
	debris_3.apply_impulse(rVector(-0.4, 12, -2), rVector(0.4, 0.5, 0.7))
	debris_4.apply_impulse(rVector(1, 5, -1), rVector(0, 0.1, 0))
	debris_1.angular_velocity=rVector(1, 0.5, 0.1)

	if alpha_tween:
		alpha_tween.kill()
	alpha_tween = get_tree().create_tween()
	alpha_tween.tween_interval(LIFETIME - FADETIME)
	alpha_tween.tween_property(debris_1.get_node('MeshInstance3D'), 'transparency', 1.0, FADETIME)
	alpha_tween.parallel().tween_property(debris_2.get_node('MeshInstance3D'), 'transparency', 1.0, FADETIME)
	alpha_tween.parallel().tween_property(debris_3.get_node('MeshInstance3D'), 'transparency', 1.0, FADETIME)
	alpha_tween.parallel().tween_property(debris_4.get_node('MeshInstance3D'), 'transparency', 1.0, FADETIME)
	alpha_tween.tween_callback(self.queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
