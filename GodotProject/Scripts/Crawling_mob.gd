extends Node3D

@onready var initiated_on = Time.get_ticks_msec()
@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var mob = $mob
@onready var helicopter = %Helicopter

@export var ROUNDS_PER_SEC = 0.05
@export var SPEED = 25
@export var PURSUIT_DISTANCE = 50
@export var ATTACK_DISTANCE = 20
@export var JUMP = 13

@export var health: float = 100
const BIG_EXPLOSION = preload("res://Scenes/big_explosion.tscn")
const DEBRIS = preload("res://Scenes/crate_debris.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func hit(force: float):
	health -= force
	if health < 0:
		var debris = DEBRIS.instantiate()
		get_tree().root.add_child(debris)
		debris.global_position = mob.global_position

		var explosion = BIG_EXPLOSION.instantiate()
		get_tree().root.add_child(explosion)
		explosion.global_position = mob.global_position
		explosion.global_rotation = mob.global_rotation
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var now = Time.get_ticks_msec()
	#path_follow_3d.progress = fmod((now-initiated_on)*ROUNDS_PER_SEC/1000, 1)
	path_follow_3d.progress_ratio = fmod((now-initiated_on)*ROUNDS_PER_SEC/1000, 1)

	var target:Node3D

	var distance_from_heli = Vector3(helicopter.global_position-mob.global_position).length()

	if distance_from_heli < PURSUIT_DISTANCE:
		target = helicopter
	else:
		target = path_follow_3d

	var thowards_target = Vector3(target.global_position-mob.global_position);
	thowards_target.y = 0;
	if thowards_target.length()>1:
		thowards_target = thowards_target.normalized()

	if distance_from_heli < ATTACK_DISTANCE:
		if mob.is_on_floor():
			mob.velocity.y = JUMP
		thowards_target = thowards_target.normalized()


	mob.velocity.x = thowards_target.x*SPEED
	mob.velocity.z = thowards_target.z*SPEED

	mob.look_at(target.global_position)

	# Add the gravity.
	if not mob.is_on_floor():
		mob.velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	mob.move_and_slide()
