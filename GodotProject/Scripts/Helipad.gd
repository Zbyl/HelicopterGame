extends Node3D
@onready var landing_marker = $LandingMarker
@onready var light_1 = $Node3D/Light1
@onready var animation_player = $AnimationPlayer

@onready var landing_timer = $LandingTimer
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
	if not GameData.game._is_landing_allowed():
		return
	if landing_started:
		return
	cancel_landing()
	landing_timer.start()

func cancel_landing():
	if landing_started:
		return
	landing_timer.stop()

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
