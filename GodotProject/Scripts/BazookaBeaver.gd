extends Node3D

@onready var mob = $mob
const ROCKET = preload("res://Scenes/rocket.tscn")
@onready var firing_marker_left = $mob/firingMarker_left
@onready var firing_marker_right = $mob/firingMarker_right


@export var AIMING_DISTANCE = 30
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
const DEBRIS = preload("res://Scenes/crate_debris.tscn")

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
		var debris = DEBRIS.instantiate()
		get_tree().root.add_child(debris)
		debris.global_position = global_position
		debris.global_position.y+=1

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
		set_state(AIMING)

	if state==AIMING && helicopter:
		mob.look_at(helicopter.global_position)
		mob.rotation.x = 0
		mob.rotation.z = 0
	else:
		mob.rotation.y = initial_rotation

	if state==AIMING && Time.get_ticks_msec()-state_changed > AIMING_TIME:
		try_to_fire()

