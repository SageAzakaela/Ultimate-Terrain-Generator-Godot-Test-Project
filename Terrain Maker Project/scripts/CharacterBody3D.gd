extends CharacterBody3D

const SPEED = 20
const JUMP_VELOCITY = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Rotate left or right.
	if Input.is_action_pressed("ui_right"):
		rotate_y(deg_to_rad(-90 * delta))
	elif Input.is_action_pressed("ui_left"):
		rotate_y(deg_to_rad(90 * delta))

	# Get the input direction and handle movement/deceleration.
	# Forward movement with up arrow, backward movement with down arrow.
	var input_dir = Vector3(0, 0, 0)
	if Input.is_action_pressed("ui_up"):
		input_dir += Vector3(0, 0, -1)
	elif Input.is_action_pressed("ui_down"):
		input_dir += Vector3(0, 0, 1)

	var direction = (transform.basis * input_dir).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
