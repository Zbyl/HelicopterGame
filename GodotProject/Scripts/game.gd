extends Node

class_name Game

@onready var hud = $Hud
const EXAMPLE_LEVEL = preload("res://Scenes/example_level.tscn")

var level

# Called when the node enters the scene tree for the first time.
func _ready():
	hud.new_game_pressed.connect(_on_new_game_pressed)
	hud.pause_game.connect(_on_pause_game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu"):
		hud.toggle_menu()

func _on_pause_game(do_pause: bool):
	print('Paused.' if do_pause else 'Unpaused.')

func _on_new_game_pressed():
	#hud._on_new_game()
	#await _switch_level(INTRO, false)
	#await level.intro_ended
	_switch_level(EXAMPLE_LEVEL, true)

func _switch_level(new_level_scene, show_weapons: bool):
	if level:
		level.queue_free()
		level = null

	# Hack to make sure we instantiate new level once old level is actually freed.
	# Otherwise we might have two Players at once etc.
	await get_tree().create_timer(0.01).timeout
	if level:
		return # Hack to avoid some race conditions.
		
	level = new_level_scene.instantiate()
	add_child(level)
	hud.show_background(false)
	hud.show_menu(false)
	#hud.show_weapons(show_weapons)
	
