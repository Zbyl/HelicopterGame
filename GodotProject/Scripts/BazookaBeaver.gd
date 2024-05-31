extends Node3D

@onready var mob = $mob
const ROCKET = preload("res://Scenes/rocket.tscn")
@onready var firing_marker_left = $mob/firingMarker_left
@onready var firing_marker_right = $mob/firingMarker_right
@onready var audio_stream_player_3d = $mob/AudioStreamPlayer3D


@export var AIMING_DISTANCE = 75
@export var AIMING_MAX_DISTANCE = 250
@export var AIMING_TIME = 300
@export var FIRE_INTERVAL = 1500
@export var BEAVER_ROCKET_SPEED = 0.6
@export var BEAVER_ROCKET_HIT_DAMAGE = 15

@onready var initial_rotation = mob.rotation.y

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
		var dir3 = Vector3(helicopter.global_position-mob.global_position)
		desired_rotation = Vector2(dir3.z, dir3.x).angle()-PI
	else:
		desired_rotation = initial_rotation

	while desired_rotation<0:
		desired_rotation += 2*PI

	while desired_rotation>=2*PI:
		desired_rotation -= 2*PI

	while mob.rotation.y<0:
		mob.rotation.y += 2*PI

	while mob.rotation.y>=2*PI:
		mob.rotation.y -= 2*PI

	if desired_rotation>mob.rotation.y && desired_rotation-PI>mob.rotation.y:
		desired_rotation -= 2*PI
	elif mob.rotation.y>desired_rotation && mob.rotation.y-PI>desired_rotation:
		desired_rotation += 2*PI

	mob.rotation.y = move_toward(mob.rotation.y, desired_rotation, 0.05)

	if state==AIMING && Time.get_ticks_msec()-state_changed > AIMING_TIME:
		try_to_fire()

