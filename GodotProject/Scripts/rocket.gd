extends Area3D

class_name Rocket

@export var speed: float = 1.0
@export var is_rocket: bool = true # true rocket, false bullet
@export var hit_damage: float = 50.0
@export var hit_force: float = 50.0

@onready var ray_cast: RayCast3D = $RayCast

const ROCKET_EXPLOSION = preload("res://Scenes/explosion.tscn")
const BULLET_EXPLOSION = preload("res://Scenes/bullet_hit.tscn")

var owner_body

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_owner_body(body):
	owner_body = body.get_instance_id()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += -transform.basis.z * speed
	#translate_object_local(transform.basis.z * speed)

func _on_body_entered(body):
	if body.get_instance_id()==owner_body:
		return

	explode()

	if body.is_in_group('Hittable'):
		print('Hitting', body.name)
		body.hit(hit_damage)

	if body.is_in_group('Pushable'):
		print('Pushing', body.name)
		var position = ray_cast.get_collision_point() if ray_cast.is_colliding() else body.global_position
		var normal = -transform.basis.z * hit_force
		var rigid_body: PhysicsBody3D = body
		rigid_body.apply_impulse(normal, position - rigid_body.global_position)

func explode():
	var explosion: Explosion = ROCKET_EXPLOSION.instantiate() if is_rocket else BULLET_EXPLOSION.instantiate()
	get_tree().root.add_child(explosion)
	var position = ray_cast.get_collision_point() if ray_cast.is_colliding() else self.global_position
	explosion.global_position = position
	explosion.global_rotation = self.global_rotation
	queue_free()

func _on_life_timer_timeout():
	explode()


func _on_area_entered(area):
	_on_body_entered(area)
