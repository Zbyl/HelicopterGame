extends CharacterBody3D

class_name Helicopter

const ROCKET = preload("res://Scenes/rocket.tscn")
@onready var rocket_cooldown_timer: Timer = $RocketCooldownTimer
const BULLET = preload("res://Scenes/bullet.tscn")
@onready var gun_cooldown_timer: Timer = $GunCooldownTimer
var active_rocket_left: bool = true # true fire left rocket next, false fire right rocket next.
@onready var helicopter_sound = $Helicopter_sound
@onready var helicopter_slowdown = $Helicopter_slowdown
@onready var helicopter_slow = $Helicopter_slow
@onready var intro_player = $Intro_player


const BIG_EXPLOSION = preload("res://Scenes/big_explosion.tscn")
const DEBRIS = preload("res://Scenes/helicopter_debris.tscn")
const HELICOPTER_HIT = preload("res://Scenes/helicopter_hit.tscn")
@export var num_debris: int = 10

@export var health: float = 100
var paused: bool = false
var landing: bool = false
var landing_helipad: Node3D

@onready var gun_marker: Marker3D = $GunMarker
@onready var rocket_left_marker: Marker3D = $RocketLeftMarker
@onready var rocket_right_marker: Marker3D = $RocketRightMarker
@onready var aim:RayCast3D = $Aim
@onready var crosshair = $Crosshair
@onready var helicopter_main_blades = $Model/HelicopterMainBlades
@onready var helicopter_back_blades = $Model/HelicopterBackBlades
@onready var collision_area = $Area3D



@onready var model = $Model
@onready var camera_3d:Camera3D = %Camera
@onready var camera_initial_transform:Transform3D = Transform3D(%Camera.transform)

#@onready var initial_altitude = global_position.y
var min_altitude = 3.0
var max_altitude = 15.0


@export var ALTITUDE_CORRECTION_FADE = 0.5
@export var UP_ACCELERATION = 1.0
@export var UP_SPEED = 20.0
@export var UP_FADE = 0.25
@export var SPEED_FORWARD = 40.0
@export var SPEED_BACKWARD = 25.0
@export var SPEED_ACCELERATION = 0.4
@export var SPEED_FADE = 0.2
@export var STRAFE_SPEED = 25.0
@export var STRAFE_ACCELERATION = 0.8
@export var STRAFE_FADE = 0.2

@export var ROT_SPEED = 0.03
@export var ROT_ACCELERATION = 0.002
@export var ROT_FADE = 0.002

@export var ROLL_MAX = 0.1
@export var ROLL_FADE = 0.01

@export var PITCH_MAX = 0.2
@export var PITCH_FADE = 0.01

@export var AIM_MAX_UP = 1.5
@export var AIM_MAX_DOWN = 0.3
@export var AIM_AT_LANDING = -0.6
@export var AIM_SPEED_SLOW = 0.01
@export var AIM_SPEED_FAST = 0.03

@export var MODEL_CAMERA_LAG = 10

@export var ROTOR_SPEED = 0.3;
@export var ROTOR_SPEED_LANDED = 0.1

@export var ALTITUDE_ADJUST = 2

var rot_current = 0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#func _ready():
#	marker = $Marker

var rel_velocity = Vector3(0, 0, 0);
var roll_angle = 0
var pitch_angle = 0

var aim_angle = 0;
var rotor_speed = ROTOR_SPEED

@export var HIT_MAX_AGE = 2000
@export var HIT_FADE = 0.1
@export var HIT_THRUST = 50
@export var HIT_ROTATION = 0.3

var hit_thrust = Vector3(0, 0, 0)
var hit_rotation = 0
@onready var hit_on = Time.get_ticks_msec()-HIT_MAX_AGE

var rng = RandomNumberGenerator.new()

func pause(do_pause: bool):
	paused = do_pause

func fire_rocket():
	if not rocket_cooldown_timer.is_stopped():
		return
	rocket_cooldown_timer.start()

	active_rocket_left = !active_rocket_left

	var rocket: Rocket = ROCKET.instantiate()
	rocket.set_owner_body(collision_area)
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

	helicopter_main_blades.rotate_y(rotor_speed)
	helicopter_back_blades.rotate_x(-rotor_speed)

func handle_input_and_movement():
	var input_rot = Input.get_axis("turn_left", "turn_right")

	if input_rot != 0:
		rot_current = move_toward(rot_current, -input_rot * ROT_SPEED, ROT_ACCELERATION)
	else:
		rot_current = move_toward(rot_current, 0, ROT_FADE)

	rotate_object_local(Vector3(0, 1, 0), rot_current+hit_rotation)

	var input_aim = Input.get_axis("aim_up", "aim_down")

	if input_aim < -0.5:
		aim_angle = move_toward(aim_angle, AIM_MAX_UP, AIM_SPEED_FAST)
	elif input_aim < 0:
		aim_angle = move_toward(aim_angle, AIM_MAX_UP, AIM_SPEED_SLOW)
	elif input_aim > 0.5:
		aim_angle = move_toward(aim_angle, -AIM_MAX_DOWN, AIM_SPEED_FAST)
	elif input_aim > 0:
		aim_angle = move_toward(aim_angle, -AIM_MAX_DOWN, AIM_SPEED_SLOW)


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

	var input_fly_up = Input.get_axis("fly_down", "fly_up")
	velocity.y += input_fly_up * UP_ACCELERATION
	rel_velocity.y = velocity.y
	if rel_velocity.y > UP_SPEED:
		rel_velocity.y = UP_SPEED
	if rel_velocity.y < -UP_SPEED:
		rel_velocity.y = -UP_SPEED
	rel_velocity.y = move_toward(rel_velocity.y, 0, UP_FADE)

	velocity = transform.basis * rel_velocity
	#velocity.y = (initial_altitude-global_position.y)*ALTITUDE_ADJUST
	velocity += hit_thrust

	camera_3d.transform = camera_initial_transform.rotated(Vector3(1, 0, 0), aim_angle)

	model.rotation.z = roll_angle
	model.rotation.x = pitch_angle
	model.rotation.y = rot_current*MODEL_CAMERA_LAG


	var visible_rect = camera_3d.get_viewport().get_visible_rect();
	var point_of_aim = camera_3d.project_position(visible_rect.position+(visible_rect.size/2), 100);
	aim.target_position = aim.to_local(point_of_aim)

	var crosshair_3d_pos = Vector3(0, 0, 0)
	if aim.is_colliding():
		crosshair_3d_pos = aim.get_collision_point()
	else:
		crosshair_3d_pos = aim.to_global(aim.position+aim.target_position)

	var crosshair_2d_pos = camera_3d.unproject_position(crosshair_3d_pos)

	crosshair.offset.x = crosshair_2d_pos.x / crosshair.scale.x
	crosshair.offset.y = crosshair_2d_pos.y / crosshair.scale.y

func landing_sequence_ended():
	GameData.game._on_landing_finished()

func handle_landing_sequence():
	if (model.global_position - landing_helipad.landing_marker.global_position).length() < 0.2:
		landing_sequence_ended()

	velocity.x = move_toward(velocity.x, 0, SPEED_FADE)
	velocity.y = move_toward(velocity.y, 0, SPEED_FADE)
	velocity.z = move_toward(velocity.z, 0, SPEED_FADE)
	model.rotation.z = move_toward(model.rotation.z, 0, ROLL_FADE)
	model.rotation.x = move_toward(model.rotation.x, 0, PITCH_FADE)
	model.rotation.y = move_toward(model.rotation.y, PI/4, 0.01)
	model.global_position.x = move_toward(model.global_position.x, landing_helipad.landing_marker.global_position.x, 0.05)
	model.global_position.y = move_toward(model.global_position.y, landing_helipad.landing_marker.global_position.y, 0.05)
	model.global_position.z = move_toward(model.global_position.z, landing_helipad.landing_marker.global_position.z, 0.05)
	aim_angle = move_toward(aim_angle, AIM_AT_LANDING, AIM_SPEED_SLOW)
	camera_3d.transform = camera_initial_transform.rotated(Vector3(1, 0, 0), aim_angle)
	rotor_speed = move_toward(rotor_speed, ROTOR_SPEED_LANDED, 0.01)


func _physics_process(delta):
	if paused:
		return


	if Input.is_action_pressed("fire_rocket"):
		fire_rocket()

	if Input.is_action_pressed("fire_gun"):
		fire_gun()


	if !landing:
		handle_input_and_movement()
	else:
		handle_landing_sequence()

	if $GroundRayCast.is_colliding():
		var ground_height = $GroundRayCast.get_collision_point().y
		var desired_height = clampf(self.global_position.y, ground_height + min_altitude, ground_height + max_altitude)
		self.global_position.y = move_toward(self.global_position.y, desired_height, ALTITUDE_CORRECTION_FADE)

	rotate_rotors()
	fade_hit()



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

func _on_body_entered(body):
	if body.is_in_group('Mob'):
		print('Hit by ', body.name)
		spawn_hit_animation()
		apply_hit_thrust()
		hit(body.hit_damage)

func spawn_hit_animation():
	var hit_animation = HELICOPTER_HIT.instantiate();
	get_tree().root.add_child(hit_animation)
	hit_animation.global_position = model.global_position
	hit_animation.global_rotation = model.global_rotation

func rnd():
	return rng.randf_range(-3, 3)

func apply_hit_thrust():
	hit_thrust = Vector3(rng.randf_range(-1, 1), 0.2, rng.randf_range(-1, 1)).normalized()*HIT_THRUST
	hit_rotation = HIT_ROTATION
	hit_on = Time.get_ticks_msec()

func fade_hit():
	var now = Time.get_ticks_msec()
	if now - hit_on > HIT_MAX_AGE:
		hit_thrust = Vector3(0, 0, 0)
		hit_rotation = 0
	else:
		hit_thrust *= (1-HIT_FADE)
		hit_rotation *= (1-HIT_FADE)

func hit(force: float) -> bool: # Returns true if object is dead.
	if health <= 0:
		return true

	health -= force
	GameData.hud.update_health_label(health)
	if health > 0:
		return false

	health = 0
	GameData.hud.update_health_label(health)
	die()
	return true

func die():
	GameData.game._on_player_died()

	for i in range(num_debris):
		var debris = DEBRIS.instantiate()
		get_tree().root.add_child(debris)
		debris.global_position = global_position + Vector3.UP * 1.0

	var explosion = BIG_EXPLOSION.instantiate()
	get_tree().root.add_child(explosion)
	explosion.global_position = self.global_position
	explosion.global_rotation = self.global_rotation
	queue_free()

func land(helipad):
	print("Helicopter landing")
	landing = true
	landing_helipad = helipad
	helicopter_sound.stop()
	helicopter_slowdown.play()

	landing_helipad.start_blinking()



func _on_helicopter_slowdown_finished():
	helicopter_slow.play()


func _on_timer_timeout():
	intro_player.play()
