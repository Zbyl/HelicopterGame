extends CanvasLayer

class_name Hud

signal new_game_pressed()
signal pause_game(do_pause: bool)

@onready var menu: Control = $Screen/Menu
@onready var controls_help: Control = $Screen/ControlsHelp
@onready var new_game_button: Button = $Screen/Menu/VBoxContainer/NewGameButton
@onready var background: Control = $Screen/Background
@onready var gauges: Control = $Screen/Gauges
@onready var health_label: Label = $Screen/Gauges/HealthLabel
@onready var portals_label: Label = $Screen/Gauges/PortalsLabel
@onready var eggs_label: Label = $Screen/Gauges/EggsLabel
@onready var mission_not_complete: Control = $Screen/MissionNotComplete
@onready var mission_not_complete_timer: Timer = $Screen/MissionNotComplete/MissionNotCompleteHideTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	controls_help.visible = false
	gauges.visible = false
	mission_not_complete.visible = false
	new_game_button.grab_focus.call_deferred()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
