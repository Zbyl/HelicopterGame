extends CharacterBody3D

class_name Helicopter

const ROCKET = preload("res://Scenes/rocket.tscn")
@onready var rocket_cooldown_timer: Timer = $RocketCooldownTimer
const BULLET = preload("res://Scenes/rocket.tscn")
@onready var gun_cooldown_timer: Timer = $GunCooldownTimer
var active_rocket_left: bool = true # true fire left rocket next, false fire right rocket next.

@onready var gun_marker: Marker3D = $GunMarker
@onready var rocket_left_marker: Marker3D = $RocketLeftMarker
@onready var rocket_right_marker: Marker3D = $RocketRightMarker


@onready var mesh_instance_3d:MeshInstance3D = $MeshInstance3D

@export var SPEED_FORWARD = 40.0
@export var SPEED_BACKWARD = 10.0
@export var SPEED_ACCELERATION = 0.4
@export var SPEED_FADE = 0.2
@export var STRAFE_SPEED = 12.0
@export var STRAFE_ACCELERATION = 0.4
@export var STRAFE_FADE = 0.2

@export var ROT_SPEED = 0.1
@export var ROT_ACCELERATION = 0.1
@export var ROT_FADE = 0.3

@export var ROLL_MAX = 0.1
@export var ROLL_FADE = 0.01

@export var PITCH_MAX = 0.2
@export var PITCH_FADE = 0.01

var rot_current = 0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#func _ready():
#	marker = $Marker

var rel_velocity = Vector3(0, 0, 0);
var roll_angle = 0
var pitch_angle = 0

func fire_rocket():
	if not rocket_cooldown_timer.is_stopped():
		return
	rocket_cooldown_timer.start()

	active_rocket_left = !active_rocket_left

	var rocket: Rocket = ROCKET.instantiate()
	get_tree().root.add_child(rocket)
	rocket.global_position = rocket_left_marker.global_position if active_rocket_left else rocket_right_marker.global_position
	rocket.global_rotation = self.global_rotation

func fire_gun():
	if not gun_cooldown_timer.is_stopped():
		return
	gun_cooldown_timer.start()

	var bullet: Rocket = BULLET.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = gun_marker.global_position
	bullet.global_rotation = self.global_rotation

func _physics_process(delta):
	if Input.is_action_pressed("fire_rocket"):
		fire_rocket()
		
	if Input.is_action_pressed("fire_gun"):
		fire_gun()
		

	# Add the gravity.
	if is_on_floor() && rel_velocity.y<0:
		rel_velocity.y = 0

	#marker.global_position

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	var input_rot = Input.get_axis("turn_left", "turn_right")

	if input_rot != 0:
		rot_current = move_toward(rot_current, -input_rot * ROT_SPEED, ROT_ACCELERATION)
	else:
		rot_current = move_toward(rot_current, 0, ROT_FADE)

	rotate_object_local(Vector3(0, 1, 0), rot_current)
	#rotate_y(rot_current)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_strafe = Input.get_axis("strafe_left", "strafe_right")

	if input_strafe != 0:
		rel_velocity.x = move_toward(rel_velocity.x, input_strafe * STRAFE_SPEED, STRAFE_ACCELERATION)
		roll_angle = move_toward(roll_angle, -input_strafe * ROLL_MAX, ROLL_FADE)
	else:
		rel_velocity.x = move_toward(rel_velocity.x, 0, STRAFE_FADE)
		roll_angle = move_toward(roll_angle, 0, ROLL_FADE)

	var input_accelerate = Input.get_axis("forward", "backward")

	if input_accelerate < 0:
		rel_velocity.z = move_toward(rel_velocity.z, input_accelerate * SPEED_FORWARD, SPEED_ACCELERATION)
		pitch_angle = move_toward(pitch_angle, input_accelerate * PITCH_MAX, PITCH_FADE)
	elif input_accelerate > 0:
		rel_velocity.z = move_toward(rel_velocity.z, input_accelerate * SPEED_BACKWARD, SPEED_ACCELERATION)
		pitch_angle = move_toward(pitch_angle, input_accelerate * PITCH_MAX, PITCH_FADE)
	else:
		rel_velocity.z = move_toward(rel_velocity.z, 0, SPEED_FADE)
		pitch_angle = move_toward(pitch_angle, 0, PITCH_FADE)

	velocity = transform.basis * rel_velocity

	mesh_instance_3d.rotation.z = roll_angle
	mesh_instance_3d.rotation.x = pitch_angle


	#var input_dir = Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
#
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#if direction.z < 0:
			#velocity.z = move_toward(velocity.z, direction.z * SPEED_FORWARD, SPEED_ACCELERATION)
		#else:
			#velocity.z = move_toward(velocity.z, direction.z * SPEED_BACKWARD, SPEED_ACCELERATION)
	#else:
		#velocity.x = move_toward(velocity.x, 0, STRAFE_FADE)
		#velocity.z = move_toward(velocity.z, 0, SPEED_FADE)

	move_and_slide()
