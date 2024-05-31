extends Node3D

@export var is_portal: bool = true
@export var health: float = 300
const EXPLOSION = preload("res://Scenes/huge_explosion.tscn")
const DEBRIS = preload("res://Scenes/portal_debris.tscn")
const PORTAL_DESTROYED_SOUND = preload("res://Scenes/Portal_destroyed_sound.tscn")
const WELL_DONE_SOUND = preload("res://Scenes/Well_done_sound.tscn")
@export var num_debris: int = 10



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func hit(force: float) -> bool: # True if died.
	health -= force
	if health > 0:
		return false
	health = 0
	die()
	return true


func die():
	if is_portal:
		GameData.game._on_portal_died()
		get_tree().root.add_child(PORTAL_DESTROYED_SOUND.instantiate())
	else:
		GameData.game._on_egg_died()
		get_tree().root.add_child(WELL_DONE_SOUND.instantiate())

	for i in range(num_debris):
		var debris = DEBRIS.instantiate()
		get_tree().root.add_child(debris)
		debris.global_position = global_position + Vector3.UP * 1

	var explosion = EXPLOSION.instantiate()
	get_tree().root.add_child(explosion)
	explosion.global_position = self.global_position
	explosion.global_rotation = self.global_rotation

	%Model.queue_free()
	%BrokenModel.visible = true
