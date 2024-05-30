extends CanvasLayer

signal new_game_pressed()
signal pause_game(do_pause: bool)

@onready var menu = $Screen/Menu
@onready var controls_help = $Screen/ControlsHelp
@onready var new_game_button = $Screen/Menu/VBoxContainer/NewGameButton
@onready var background = $Screen/Background

# Called when the node enters the scene tree for the first time.
func _ready():
	controls_help.visible = false
	new_game_button.grab_focus.call_deferred()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func toggle_menu():
	show_menu(!menu.visible)

func show_menu(do_show: bool):
	menu.visible = do_show
	controls_help.visible = false
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
