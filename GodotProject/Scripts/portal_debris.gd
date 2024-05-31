extends Node3D

class_name PortalDebris

@onready var debris: RigidBody3D = $Debris

var alpha_tween: Tween

@export var LIFETIME: float = 5.0 # Lifetime in seconds.
@export var FADETIME: float = 1.0 # Fade out time in seconds (within LIFETIME).
@export var poke_strength: float = 15.0
@export var poke_dist_min: float = 0.0
@export var poke_dist_max: float = 1.0

@onready var initiated_on = Time.get_ticks_msec()

static func rand_normal() -> Vector3:
	var t = randf_range(0.0, 1.0) * PI * 2
	var u = -randf_range(0.2, 1.0) * PI / 2
	var v = Vector3(sin(t), 0.0, cos(t))
	var w = Vector3(cos(t), 0.0, -sin(t))
	return v.rotated(w, u)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	debris.apply_impulse(rand_normal() * poke_strength, rand_normal() * randf_range(poke_dist_min, poke_dist_max))

	if alpha_tween:
		alpha_tween.kill()
	alpha_tween = get_tree().create_tween()
	alpha_tween.tween_interval(LIFETIME - FADETIME)
	alpha_tween.tween_property(debris.get_node('MeshInstance3D'), 'transparency', 1.0, FADETIME)
	alpha_tween.tween_callback(self.queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
