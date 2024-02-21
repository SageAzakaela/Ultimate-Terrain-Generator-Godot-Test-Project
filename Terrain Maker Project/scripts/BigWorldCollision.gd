extends "res://scripts/CollisionMapClass.gd"


@export_file("*.png") var height_map_path: String


func _ready():
	image = load(height_map_path).get_image()
	physics_body = get_parent().get_parent().player_character
	size = image.get_width()
	update_shape()

func _physics_process(_delta):
	var player_rounded_position = physics_body.global_position.snapped(snap) * Vector3(1,0,1)
	if not global_position == player_rounded_position:
		global_position = player_rounded_position
		update_shape()
