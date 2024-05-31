extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed('ui_accept'):
		if not GameData.hud.menu.visible:
			GameData.hud.show_menu(true)


func _on_timer_timeout():
	if not GameData.hud.menu.visible:
		GameData.hud.show_menu(true)
