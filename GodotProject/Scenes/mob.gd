extends CharacterBody3D

@onready var crawling_mob = $".."

func hit(force: float):
	crawling_mob.hit(force)

func _physics_process(delta):
	pass
