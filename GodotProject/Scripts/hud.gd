extends CanvasLayer

class_name Hud

signal new_game_pressed()
signal pause_game(do_pause: bool)

@onready var fog = $Screen/Fog
@onready var menu: Control = $Screen/Menu
@onready var controls_help: Control = $Screen/ControlsHelp
@onready var new_game_button: Button = $Screen/Menu/VBox/VBoxContainer/NewGameButton
@onready var background: Control = $Screen/Background
@onready var gauges: Control = $Screen/Gauges
@onready var health_label: Label = $Screen/Gauges/HealthLabel
@onready var portals_label: Label = $Screen/Gauges/PortalsLabel
@onready var eggs_label: Label = $Screen/Gauges/EggsLabel
@onready var mission_not_complete: Control = $Screen/MissionNotComplete
@onready var mission_not_complete_timer: Timer = $Screen/MissionNotComplete/MissionNotCompleteHideTimer
@onready var radar = $Screen/Gauges/Radar

# Called when the node enters the scene tree for the first time.
func _ready():
	controls_help.visible = false
	gauges.visible = false
	mission_not_complete.visible = false
	new_game_button.grab_focus.call_deferred()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Screen/Gauges/FPSCounter.text = "{amount} FPS".format({"amount": Engine.get_frames_per_second()})


func update_health_label(amount):
	health_label.text = "{amount}".format({"amount": amount})

func update_portals_label(amount, total):
	portals_label.text = "{amount} / {total}".format({"amount": amount, "total": total})

func update_eggs_label(amount, total):
	eggs_label.text = "{amount} / {total}".format({"amount": amount, "total": total})


func toggle_menu():
	show_menu(!menu.visible)

func show_menu(do_show: bool):
	menu.visible = do_show
	fog.visible = do_show
	controls_help.visible = false
	gauges.visible = !do_show && GameData.game.is_in_level()
	if do_show:
		new_game_button.grab_focus.call_deferred()
	pause_game.emit(do_show)

func show_background(do_show: bool):
	background.visible = do_show


func _on_new_game_button_pressed():
	new_game_pressed.emit()

func _on_exit_game_button_pressed():
	get_tree().quit()

func _on_controls_button_pressed():
	controls_help.visible = !controls_help.visible

func _on_full_screen_button_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func show_mission_not_complete():
	if mission_not_complete.visible:
		return
	mission_not_complete.visible = true
	mission_not_complete_timer.start()


func _on_mission_not_complete_hide_timer_timeout():
	mission_not_complete.visible = false

var spots = []
var max_dist = 500

func clear_radar_spots():
	for spot in spots:
		spot.queue_free()
	spots = []

func convert_to_radar(v:Vector2):
	if v.length()>max_dist:
		v = v.normalized()*max_dist

	return Vector2(v.x/max_dist*50+43, v.y/max_dist*50+43)

func add_spot(spot_scene, v):
	var spot = spot_scene.instantiate();
	radar.add_child(spot)
	spots.append(spot)
	spot.position = convert_to_radar(v)
