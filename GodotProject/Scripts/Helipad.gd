extends Node3D
@onready var landing_marker = $LandingMarker
@onready var light_1 = $Node3D/Light1
@onready var animation_player = $AnimationPlayer

@export var LANDING_DELAY = 1

var landing_timer
var landing_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_blinking():
	animation_player.play("landing_sequence")

func start_landing():
	landing_started = true
	var helicopter = get_tree().get_first_node_in_group("Player")
	if helicopter:
		helicopter.land(self)

func try_landing():
	if landing_started:
		return
	cancel_landing()
	landing_timer = Timer.new()
	landing_timer.wait_time = LANDING_DELAY
	landing_timer.one_shot = true
	landing_timer.autostart = true
	landing_timer.connect("timeout", start_landing)
	add_child(landing_timer)

func cancel_landing():
	if landing_started || !landing_timer:
		return
	landing_timer.stop()
	remove_child(landing_timer)

func _on_area_3d_area_entered(area):
	var helicopter = get_tree().get_first_node_in_group("Player")
	if helicopter && area.owner==helicopter:
		print("Landing?")
		try_landing()


func _on_area_3d_area_exited(area):
	var helicopter = get_tree().get_first_node_in_group("Player")
	if helicopter && area.owner==helicopter:
		print("No landing")
		cancel_landing()
