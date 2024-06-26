extends Node3D

var paused: bool = false

@onready var mob = $mob
const ROCKET = preload("res://Scenes/rocket.tscn")
@onready var firing_marker_left = $"mob/model/GunHolder-col2/firingMarker_left"
@onready var firing_marker_right = $"mob/model/GunHolder-col2/firingMarker_right"
@onready var audio_stream_player_3d = $mob/AudioStreamPlayer3D
@onready var gun_holder = $"mob/model/GunHolder-col2"


@export var AIMING_DISTANCE = 75
@export var AIMING_MAX_DISTANCE = 150
@export var AIMING_TIME = 300
@export var FIRE_INTERVAL = 1500
@export var BEAVER_ROCKET_SPEED = 0.6
@export var BEAVER_ROCKET_HIT_DAMAGE = 15
@export var GUN_HOLDER_CORRECTION = 0.85

@onready var initial_rotation = rotation.y

var helicopter

enum {CALM, AIMING}

var state = CALM
var state_changed = Time.get_ticks_msec()

@export var health: float = 100
const BIG_EXPLOSION = preload("res://Scenes/blood_explosion.tscn")
const DEBRIS = preload("res://Scenes/guts_debris.tscn")
@export var num_debris: int = 10

var left_fired = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_state(new_state):
	state = new_state
	state_changed = Time.get_ticks_msec()

func hit(force):
	health -= force
	if health < 0:
		for i in range(num_debris):
			var debris = DEBRIS.instantiate()
			get_tree().root.add_child(debris)
			debris.global_position = global_position + Vector3.UP * 1

		var explosion = BIG_EXPLOSION.instantiate()
		get_tree().root.add_child(explosion)
		explosion.global_position = self.global_position
		explosion.global_rotation = self.global_rotation
		queue_free()

var last_fired = Time.get_ticks_msec()-AIMING_TIME

func do_fire():
	last_fired = Time.get_ticks_msec()

	var firing_marker
	if left_fired:
		firing_marker = firing_marker_right
	else:
		firing_marker = firing_marker_left

	left_fired = !left_fired

	var rocket: Rocket = ROCKET.instantiate()
	rocket.speed = BEAVER_ROCKET_SPEED
	rocket.rocket_hit_damage = BEAVER_ROCKET_HIT_DAMAGE
	rocket.set_owner_body(mob)
	get_tree().root.add_child(rocket)
	rocket.global_position = firing_marker.global_position
	rocket.look_at(helicopter.global_position)

func try_to_fire():
	var now = Time.get_ticks_msec()
	if helicopter && now-last_fired > FIRE_INTERVAL:
		do_fire()

func pause(do_pause: bool):
	paused = do_pause

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return

	helicopter = get_tree().get_first_node_in_group("Player")

	var distance_from_heli;

	if helicopter:
		distance_from_heli = Vector3(helicopter.global_position-mob.global_position).length()
	else:
		distance_from_heli = 100000

	if state==CALM && distance_from_heli < AIMING_DISTANCE:
		audio_stream_player_3d.play()
		set_state(AIMING)

	if state==AIMING && distance_from_heli > AIMING_MAX_DISTANCE:
		set_state(CALM)

	var desired_rotation:float
	if state==AIMING && helicopter:
		var dir3 = Vector3(helicopter.global_position-mob.global_position).normalized()
		var dir2 = Vector2(dir3.z, dir3.x)
		desired_rotation = dir2.angle()-PI
		var alt = Vector2(dir3.y, dir2.length()).angle()
		gun_holder.rotation.z = alt-GUN_HOLDER_CORRECTION
	else:
		desired_rotation = initial_rotation

	while desired_rotation<0:
		desired_rotation += 2*PI

	while desired_rotation>=2*PI:
		desired_rotation -= 2*PI

	while rotation.y<0:
		rotation.y += 2*PI

	while rotation.y>=2*PI:
		rotation.y -= 2*PI

	if desired_rotation>rotation.y && desired_rotation-PI>rotation.y:
		desired_rotation -= 2*PI
	elif rotation.y>desired_rotation && rotation.y-PI>desired_rotation:
		desired_rotation += 2*PI

	rotation.y = move_toward(rotation.y, desired_rotation, 0.05)

	if state==AIMING && Time.get_ticks_msec()-state_changed > AIMING_TIME:
		try_to_fire()

