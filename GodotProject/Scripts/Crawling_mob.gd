extends Node3D

@onready var initiated_on = Time.get_ticks_msec()
@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var mob = $mob
@onready var helicopter = %HelicopterMain

@export var ROUNDS_PER_SEC = 0.05
@export var SPEED = 12
@export var PURSUIT_SPEED = 25
@export var SPEED_FADE = 0.7
@export var PURSUIT_DISTANCE = 50
@export var ATTACK_DISTANCE = 20
@export var JUMP = 13
@export var ATTACK_COOLDOWN = 1000
@export var PURSUIT_COOLDOWN = 4000

@export var health: float = 100
var paused: bool = false
const BIG_EXPLOSION = preload("res://Scenes/big_explosion.tscn")
const DEBRIS = preload("res://Scenes/crate_debris.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {CALM, IN_PURSUIT, ATTACKING}

var state = CALM
var state_changed = Time.get_ticks_msec()



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func pause(do_pause: bool):
	paused = do_pause

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

func set_state(new_state):
	state = new_state
	state_changed = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return

	var now = Time.get_ticks_msec()
	#path_follow_3d.progress = fmod((now-initiated_on)*ROUNDS_PER_SEC/1000, 1)
	path_follow_3d.progress_ratio = fmod((now-initiated_on)*ROUNDS_PER_SEC/1000, 1)

	var target:Node3D

	var distance_from_heli;

	if helicopter!=null:
		distance_from_heli = Vector3(helicopter.global_position-mob.global_position).length()
	else:
		distance_from_heli = 100000

	if state==CALM && distance_from_heli < PURSUIT_DISTANCE:
		set_state(IN_PURSUIT)

	if state==IN_PURSUIT || state==ATTACKING:
		target = helicopter
	else:
		target = path_follow_3d


	var thowards_target = Vector3(target.global_position-mob.global_position);
	thowards_target.y = 0;
	if thowards_target.length()>1:
		thowards_target = thowards_target.normalized()

	if mob.is_on_floor() && distance_from_heli < ATTACK_DISTANCE && state!=ATTACKING:
		mob.velocity.y = JUMP
		set_state(ATTACKING)


	if mob.is_on_floor() && state==IN_PURSUIT:
		mob.velocity.x = move_toward(mob.velocity.x, thowards_target.x*PURSUIT_SPEED, SPEED_FADE)
		mob.velocity.z = move_toward(mob.velocity.z, thowards_target.z*PURSUIT_SPEED, SPEED_FADE)
	elif state==CALM:
		mob.velocity.x = thowards_target.x*SPEED
		mob.velocity.z = thowards_target.z*SPEED

	mob.look_at(target.global_position)

	# Add the gravity.
	if not mob.is_on_floor():
		mob.velocity.y -= gravity * delta

	if state==ATTACKING && Time.get_ticks_msec() - state_changed > ATTACK_COOLDOWN:
		set_state(IN_PURSUIT)
	elif state!=CALM && Time.get_ticks_msec() - state_changed > PURSUIT_COOLDOWN:
		set_state(CALM)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	mob.move_and_slide()
