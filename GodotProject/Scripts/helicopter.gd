extends CharacterBody3D

class_name Helicopter

const ROCKET = preload("res://Scenes/rocket.tscn")
@onready var rocket_cooldown_timer: Timer = $RocketCooldownTimer
const BULLET = preload("res://Scenes/bullet.tscn")
@onready var gun_cooldown_timer: Timer = $GunCooldownTimer
var active_rocket_left: bool = true # true fire left rocket next, false fire right rocket next.

@onready var gun_marker: Marker3D = $GunMarker
@onready var rocket_left_marker: Marker3D = $RocketLeftMarker
@onready var rocket_right_marker: Marker3D = $RocketRightMarker
@onready var aim:RayCast3D = $Aim
@onready var canvas_layer = $CanvasLayer
@onready var crosshair = $Crosshair
@onready var helicopter_main_blades = $Model/HelicopterMainBlades
@onready var helicopter_back_blades = $Model/HelicopterBackBlades



@onready var model = $Model
@onready var camera_3d:Camera3D = $Camera3D
@onready var camera_initial_transform:Transform3D = Transform3D($Camera3D.transform)


@export var SPEED_FORWARD = 40.0
@export var SPEED_BACKWARD = 10.0
@export var SPEED_ACCELERATION = 0.4
@export var SPEED_FADE = 0.2
@export var STRAFE_SPEED = 12.0
@export var STRAFE_ACCELERATION = 0.4
@export var STRAFE_FADE = 0.2

@export var ROT_SPEED = 0.03
@export var ROT_ACCELERATION = 0.1
@export var ROT_FADE = 0.3

@export var ROLL_MAX = 0.1
@export var ROLL_FADE = 0.01

@export var PITCH_MAX = 0.2
@export var PITCH_FADE = 0.01

@export var CAMERA_MAX_LAG = 0.7
@export var CAMERA_FADE = 0.02

@export var AIM_MAX_UP = 0.2
@export var AIM_MAX_DOWN = 0.5
@export var AIM_FADE = 0.015

@export var ROTOR_SPEED = 0.3;

var rot_current = 0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#func _ready():
#	marker = $Marker

var rel_velocity = Vector3(0, 0, 0);
var roll_angle = 0
var pitch_angle = 0

var aim_angle = 0;

var camera_lag = 0;

func fire_rocket():
	if not rocket_cooldown_timer.is_stopped():
		return
	rocket_cooldown_timer.start()

	active_rocket_left = !active_rocket_left

	var rocket: Rocket = ROCKET.instantiate()
	get_tree().root.add_child(rocket)
	rocket.global_position = rocket_left_marker.global_position if active_rocket_left else rocket_right_marker.global_position
	rocket.look_at(aim.to_global(aim.position + aim.target_position))

func fire_gun():
	if not gun_cooldown_timer.is_stopped():
		return
	gun_cooldown_timer.start()

	var bullet: Rocket = BULLET.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = gun_marker.global_position
	bullet.look_at(aim.to_global(aim.position + aim.target_position))

func rotate_rotors():
	var now = Time.get_ticks_msec()

	helicopter_main_blades.rotate_y(ROTOR_SPEED)
	helicopter_back_blades.rotate_x(-ROTOR_SPEED)


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
		camera_lag = move_toward(camera_lag, input_rot*CAMERA_MAX_LAG, CAMERA_FADE)
	else:
		rot_current = move_toward(rot_current, 0, ROT_FADE)
		camera_lag = move_toward(camera_lag, 0, CAMERA_FADE)

	rotate_object_local(Vector3(0, 1, 0), rot_current)

	var input_aim = Input.get_axis("aim_up", "aim_down")

	if input_aim < 0:
		aim_angle = move_toward(aim_angle, -input_aim*AIM_MAX_UP, AIM_FADE)
	elif input_aim > 0:
		aim_angle = move_toward(aim_angle, -input_aim*AIM_MAX_DOWN, AIM_FADE)
	else:
		aim_angle = move_toward(aim_angle, 0, AIM_FADE)

	aim.rotation.x = aim_angle

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

	model.rotation.z = roll_angle
	model.rotation.x = pitch_angle

	camera_3d.transform = camera_initial_transform.rotated(Vector3(0, 1, 0), camera_lag)

	var crosshair_3d_pos = Vector3(0, 0, 0)
	if aim.is_colliding():
		crosshair_3d_pos = aim.get_collision_point()
	else:
		crosshair_3d_pos = aim.to_global(aim.position+aim.target_position)

	var crosshair_2d_pos = camera_3d.unproject_position(crosshair_3d_pos)

	crosshair.offset.x = crosshair_2d_pos.x / crosshair.scale.x
	crosshair.offset.y = crosshair_2d_pos.y / crosshair.scale.y

	rotate_rotors()

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
