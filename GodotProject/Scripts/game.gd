extends Node

class_name Game

@onready var hud: Hud = %Hud
const EXAMPLE_LEVEL = preload("res://Scenes/example_level.tscn")

var level
var death_camera: Camera3D = null # Camera we use after player died.

# Called when the node enters the scene tree for the first time.
func _ready():
	hud.new_game_pressed.connect(_on_new_game_pressed)
	hud.pause_game.connect(_on_pause_game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu"):
		hud.toggle_menu()

func _on_pause_game(do_pause: bool):
	print('Pausing.' if do_pause else 'Unpausing.')
	pause_player_and_enemies(do_pause)

func _on_new_game_pressed():
	#hud._on_new_game()
	#await _switch_level(INTRO, false)
	#await level.intro_ended
	await _switch_level(EXAMPLE_LEVEL, true)
	
func _switch_level(new_level_scene, show_weapons: bool):
	if death_camera:
		death_camera.queue_free()
		death_camera = null
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
	
func pause_player_and_enemies(do_pause: bool):
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.pause(do_pause)
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.pause(do_pause)

func _on_player_died(): # Called by Helicopter when its health drops to zero.
	GameData.game.pause_player_and_enemies(true)
	var player = get_tree().get_first_node_in_group("Player")
	death_camera = player.get_node('%Camera')
	death_camera.reparent(get_tree().root)
	
	await get_tree().create_timer(2).timeout
	hud.show_menu(true)
	
