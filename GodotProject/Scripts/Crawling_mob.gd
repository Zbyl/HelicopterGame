extends Node3D

@onready var initiated_on = Time.get_ticks_msec()
@onready var path_follow_3d = $Path3D/PathFollow3D
@onready var mob = $mob
var helicopter
@onready var animation_player:AnimationPlayer = $mob/Node3D/Shark/AnimationPlayer
@onready var audio_shark_angry = $mob/Shark_angry
@onready var audio_shark_attack = $mob/Shark_attack


@export var ROUNDS_PER_SEC = 0.05
@export var SPEED = 12
@export var PURSUIT_SPEED = 25
@export var SPEED_FADE = 0.7
@export var PURSUIT_DISTANCE = 75
@export var ATTACK_DISTANCE = 20
@export var ATTACK_COOLDOWN = 1000
@export var PURSUIT_COOLDOWN = 4000
@export var JUMP_FACTOR = 2.25
@export var VERTICAL_LIMIT_LIMIT = 15
@export var VERTICAL_VELOCITY_FADE = 0.5
@export var GRAVITY_FACTOR = 2

@export var health: float = 60
var paused: bool = false
const BIG_EXPLOSION = preload("res://Scenes/blood_explosion.tscn")
const DEBRIS = preload("res://Scenes/guts_debris.tscn")
@export var num_debris: int = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")*GRAVITY_FACTOR

enum {CALM, IN_PURSUIT, ATTACKING}

var state = CALM
var state_changed = Time.get_ticks_msec()



# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("Shark_swimming")

func pause(do_pause: bool):
	paused = do_pause

func hit(force: float):
	health -= force
	if health < 0:
		for i in range(num_debris):
			var debris = DEBRIS.instantiate()
			get_tree().root.add_child(debris)
			debris.global_position = mob.global_position + Vector3.UP * 1.0

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

	helicopter = get_tree().get_first_node_in_group("Player")

	var distance_from_heli;

	if helicopter:
		distance_from_heli = Vector3(helicopter.global_position-mob.global_position).length()
	else:
		distance_from_heli = 100000

	if state==CALM && distance_from_heli < PURSUIT_DISTANCE:
		audio_shark_angry.play()
		set_state(IN_PURSUIT)

	if state==IN_PURSUIT || state==ATTACKING:
		target = helicopter
	else:
		target = path_follow_3d


	if target:
		var thowards_target = Vector3(target.global_position-mob.global_position);
		thowards_target.y = 0;
		if thowards_target.length()>1:
			thowards_target = thowards_target.normalized()

		if mob.is_on_floor() && distance_from_heli < ATTACK_DISTANCE && state!=ATTACKING:
			mob.velocity.y = abs(mob.global_position.y-helicopter.global_position.y)*JUMP_FACTOR
			audio_shark_attack.play()
			set_state(ATTACKING)


		if mob.is_on_floor() && state==IN_PURSUIT:
			mob.velocity.x = move_toward(mob.velocity.x, thowards_target.x*PURSUIT_SPEED, SPEED_FADE)
			mob.velocity.z = move_toward(mob.velocity.z, thowards_target.z*PURSUIT_SPEED, SPEED_FADE)
		elif state==CALM:
			mob.velocity.x = thowards_target.x*SPEED
			mob.velocity.z = thowards_target.z*SPEED

		mob.look_at(target.global_position)
	mob.rotation.x = 0
	mob.rotation.z = 0

	# Add the gravity.
	if not mob.is_on_floor():
		mob.velocity.y -= gravity * delta

	if mob.global_position.y > VERTICAL_LIMIT_LIMIT && mob.velocity.y>0:
		mob.velocity.y = move_toward(mob.velocity.y, 0, VERTICAL_VELOCITY_FADE)

	if state==ATTACKING && Time.get_ticks_msec() - state_changed > ATTACK_COOLDOWN:
		audio_shark_angry.play()
		set_state(IN_PURSUIT)
	elif state!=CALM && Time.get_ticks_msec() - state_changed > PURSUIT_COOLDOWN:
		set_state(CALM)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	mob.move_and_slide()
