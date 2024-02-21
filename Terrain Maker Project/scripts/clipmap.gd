extends Node3D

@export var player_character:Node3D

func _physics_process(_delta):
	global_position = player_character.global_position.round() * Vector3(1,0,1)
