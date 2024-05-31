extends Node3D

@onready var crawling_mob = $".."

@export var hit_damage: float = 7.0

func hit(force: float):
	crawling_mob.hit(force)
