extends Node3D


var alpha_tween: Tween

func _on_timer_timeout():
	alpha_tween = get_tree().create_tween()
	alpha_tween.tween_property($Decala, 'modulate:a', 0.0, 1.0)
	alpha_tween.tween_callback(self.queue_free)
	
