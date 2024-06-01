extends Area3D

class_name Rocket

@export var speed: float = 1.0
@export var is_rocket: bool = true # true rocket, false bullet
@export var rocket_hit_damage: float = 30.0
@export var gun_hit_damage: float = 10.0
@export var hit_force: float = 50.0

@onready var ray_cast: RayCast3D = $RayCast
@onready var audio_stream_player_3d = $AudioStreamPlayer3D

const ROCKET_EXPLOSION = preload("res://Scenes/explosion.tscn")
const BULLET_EXPLOSION = preload("res://Scenes/bullet_hit.tscn")
const ROCKET_DECAL = preload("res://Scenes/rocket_decal.tscn")

var owner_body

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_stream_player_3d.play()
	if not is_rocket:
		$RayCast.queue_free()

func set_owner_body(body):
	owner_body = body.get_instance_id()

var paused: bool = false

func pause(do_pause: bool):
	paused = do_pause

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return

	global_position += -transform.basis.z * speed
	#translate_object_local(transform.basis.z * speed)

func _on_body_entered(body):
	if body.get_instance_id()==owner_body:
		return

	var v = Vector3(basis*Vector3(0, 0, 1))
	if body.name=='HTerrain' && v.y<0:
		return

	explode()

	if body.is_in_group('Hittable'):
		print('Hitting', body.name)
		body.hit(rocket_hit_damage if is_rocket else gun_hit_damage)

	if body.is_in_group('Pushable'):
		print('Pushing', body.name)
		var position = ray_cast.get_collision_point() if ray_cast.is_colliding() else body.global_position
		var normal = -transform.basis.z * hit_force
		var rigid_body: PhysicsBody3D = body
		rigid_body.apply_impulse(normal, position - rigid_body.global_position)

func explode():
	var explosion: Explosion = ROCKET_EXPLOSION.instantiate() if is_rocket else BULLET_EXPLOSION.instantiate()
	get_tree().root.add_child(explosion)

	if not is_rocket:
		var position = self.global_position

		explosion.global_position = position
		explosion.global_rotation = self.global_rotation
	else:
		var position = ray_cast.get_collision_point() if ray_cast.is_colliding() else self.global_position

		explosion.global_position = position
		explosion.global_rotation = self.global_rotation

		var decal: Node3D = ROCKET_DECAL.instantiate() if is_rocket else ROCKET_DECAL.instantiate()
		get_tree().root.add_child(decal)

		var normal = ray_cast.get_collision_normal() if ray_cast.is_colliding() else self.transform.basis.y
		#print('col ', ray_cast.is_colliding(), ' norm ', ray_cast.get_collision_normal())
		var do_look_at = true
		if normal.dot(Vector3.UP) > 0.3:
			do_look_at = false
		else:
			normal = self.transform.basis.y
		decal.global_position = position - normal * 0.5
		if do_look_at:
			decal.look_at(position + normal)

	queue_free()

func _on_life_timer_timeout():
	explode()


func _on_area_entered(area):
	_on_body_entered(area)
