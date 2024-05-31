extends Node

class_name Game

@onready var hud: Hud = %Hud
const EXAMPLE_LEVEL = preload("res://Scenes/example_level.tscn")
const SUCCESS_SCREEN = preload("res://Scenes/success_screen.tscn")

var level
var death_camera: Camera3D = null # Camera we use after player died.

var total_portals: int = 0	# Number of portals in the level on the start.
var total_eggs: int = 0	# Number of eggs in the level on the start.
var total_sharks: int = 0	# Number of sharks in the level on the start.
var total_beavers: int = 0	# Number of beavers in the level on the start.

# Updated on demand.
var alive_portals: int = 0	# Number of portals still alive.
var alive_eggs: int = 0	# Number of eggs still alive.
var alive_sharks: int = 0	# Number of sharks still alive.
var alive_beavers: int = 0	# Number of beavers still alive.

enum MusicKind { MENU, LEVEL, SUCCESS, FAILED }

func play_music(kind: MusicKind):
	if kind == MusicKind.MENU:
		if not $MenuMusic.playing:
			$MenuMusic.play()
	else:
		$MenuMusic.stop()

	if kind == MusicKind.LEVEL:
		if not $MenuMusic.playing:
			$LevelMusic.play()
	else:
		$LevelMusic.stop()

	if kind == MusicKind.SUCCESS:
		if not $MenuMusic.playing:
			$SuccessMusic.play()
	else:
		$SuccessMusic.stop()

	if kind == MusicKind.FAILED:
		if not $MenuMusic.playing:
			$FailedMusic.play()
	else:
		$FailedMusic.stop()

# Called when the node enters the scene tree for the first time.
func _ready():
	hud.new_game_pressed.connect(_on_new_game_pressed)
	hud.pause_game.connect(_on_pause_game)
	play_music(MusicKind.MENU)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu"):
		hud.toggle_menu()

	if Input.is_action_just_pressed("debug_button"):
		#_on_game_success()
		pass

func _on_pause_game(do_pause: bool):
	print('Pausing.' if do_pause else 'Unpausing.')
	pause_player_and_enemies(do_pause)

func _on_new_game_pressed():
	#hud._on_new_game()
	#await _switch_level(INTRO, false)
	#await level.intro_ended
	await _switch_level(EXAMPLE_LEVEL, true)

	play_music(MusicKind.LEVEL)

	#await get_tree().create_timer(0.01).timeout
	total_portals = get_tree().get_nodes_in_group('Portals').size()
	total_eggs = get_tree().get_nodes_in_group('Eggs').size()
	total_sharks = get_tree().get_nodes_in_group('Sharks').size()
	total_beavers = get_tree().get_nodes_in_group('Beavers').size()
	update_counters()
	
func is_in_level():
	return level.name == 'ExampleLevel'

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

func _on_player_died(): # Called by Helicopter when its health drops to zero, before queue_free()!
	GameData.game.pause_player_and_enemies(true)
	var player = get_tree().get_first_node_in_group("Player")
	death_camera = player.get_node('%Camera')
	death_camera.reparent(get_tree().root)
	
	play_music(MusicKind.FAILED)

	await get_tree().create_timer(2).timeout
	hud.show_menu(true)
	
func _on_game_success(): # Called by Helicopter when its health drops to zero, before queue_free()!
	print('_on_game_success()')
	GameData.game.pause_player_and_enemies(true)
	
	play_music(MusicKind.SUCCESS)

	await get_tree().create_timer(1).timeout
	await _switch_level(SUCCESS_SCREEN, true)
	
func _on_portal_died(): # Called by portal when its health drops to zero, before queue_free()!
	#update_counters()
	pass

func _on_egg_died(): # Called by egg when its health drops to zero, before queue_free()!
	#update_counters()
	pass

func _is_landing_allowed() -> bool:
	if (alive_portals > 0) or (alive_eggs > 0):
		hud.show_mission_not_complete()
		return false
	return true

func _on_landing_finished():
	_on_game_success()

func update_counters():
	alive_portals = get_tree().get_nodes_in_group('Portals').size()
	alive_eggs = get_tree().get_nodes_in_group('Eggs').size()
	alive_sharks = get_tree().get_nodes_in_group('Sharks').size()
	alive_beavers = get_tree().get_nodes_in_group('Beavers').size()
	hud.update_portals_label(total_portals - alive_portals, total_portals)
	hud.update_eggs_label(total_eggs - alive_eggs, total_eggs)
