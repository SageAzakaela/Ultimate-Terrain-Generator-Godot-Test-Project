extends CollisionShape3D

var physics_body:Node3D

@export var template_mesh:PlaneMesh
@onready var faces = template_mesh.get_faces()
@onready var snap = Vector3.ONE * template_mesh.size.x/2
@export var amplitude:float = 900
var image
var size
@export var size_modifier : float = 3

func _ready():
	physics_body = get_parent().get_parent().player_character
	size = image.get_width()
	update_shape()
	
func get_height(x, z):
	var scaled_x = fposmod(x / size_modifier, size)
	var scaled_z = fposmod(z / size_modifier, size)
	return image.get_pixel(scaled_x, scaled_z).r * amplitude

	
func _physics_process(_delta):
	var player_rounded_position = physics_body.global_position.snapped(snap) * Vector3(1,0,1)
	if not global_position == player_rounded_position:
		global_position = player_rounded_position
		update_shape()
	
func update_shape():
	for i in faces.size():
		var global_vert = faces[i] + global_position
		faces[i].y = get_height(global_vert.x,global_vert.z)
	shape.set_faces(faces)
