extends CharacterBody3D

@export var speed := 4.0

@export var model: Node3D
@export var animation_tree: AnimationTree

var current_animation := PlayerAnimations.WalkAnimations.idle
var camera: Camera3D
var speed_adjusted := speed
var initial_rotation := rotation.y
var knockback_vector := Vector3.ZERO
var direction := Vector3.ZERO

func _ready() -> void:
	camera = get_viewport().get_camera_3d()

func getRotationDirection(originalDirection: Vector2) -> Vector3:
	var vectorThree = Vector3(originalDirection.x, 0, originalDirection.y).normalized()
	return vectorThree \
		.rotated(Vector3(0, 1, 0), rotation.y - initial_rotation) \
		.rotated(Vector3(1, 0, 0), cos(rotation.y) * rotation.x) \
		.rotated(Vector3(0, 0, 1), -sin(rotation.y) * rotation.x)


func set_direction(knockback_direction: Vector3, knockback_speed: float, duration: float) -> void:
	speed_adjusted = knockback_speed
	var current_direction = direction
	if knockback_direction == Vector3.ZERO:
		knockback_vector += current_direction
	else:
		knockback_vector += knockback_direction
	await get_tree().create_timer(duration).timeout
	if knockback_direction == Vector3.ZERO:
		knockback_vector -= current_direction
	else:
		knockback_vector = Vector3.ZERO
	speed_adjusted = speed

func adjust_speed(new_speed: float, duration: float) -> void:
	speed_adjusted = new_speed
	await get_tree().create_timer(duration).timeout
	speed_adjusted = speed

const rotations = {
	-314: "forward",
	314: "forward",
	0: "back",
	157: "right",
	-157: "left",
}
func set_walking_animation():
		# if the player isnt moving, set the idle animation to play, otherwise do the running animation
	if direction == Vector3.ZERO:
		if current_animation != PlayerAnimations.WalkAnimations.idle:
			animation_tree.set_passive(PlayerAnimations.WalkAnimations.idle)
			current_animation = PlayerAnimations.WalkAnimations.idle
	else:
		# we use angle to determine the angle the model is facing (aka the mouse) vs the direction the player is moving
		# this gives us the forwards and backwards directions, but the angle doesnt do negative values so we dont know when its left/right
		# so we use the cross/dot product here to determine if the angle is negative or positive
		# positive = right, negative = left
		# we then figure out which of the four directions the current angle is closest to
		# and set the animation to the most appropriate one
		# check the animation tree node on the player for the actual animations and blending
		var angle = int(model.global_basis.z.angle_to(direction) * 100)
		var cross = model.global_basis.z.cross(direction)
		var dot = cross.dot(Vector3.UP)
		if dot < 0:
			angle = - angle

		var closest_angle = 0
		for key in rotations:
			if abs(angle - key) < abs(angle - closest_angle):
				closest_angle = key
		match rotations[closest_angle]:
			"left":
				if current_animation != PlayerAnimations.WalkAnimations.left:
					animation_tree.set_passive(PlayerAnimations.WalkAnimations.left)
					current_animation = PlayerAnimations.WalkAnimations.left
			"right":
				if current_animation != PlayerAnimations.WalkAnimations.right:
					animation_tree.set_passive(PlayerAnimations.WalkAnimations.right)
					current_animation = PlayerAnimations.WalkAnimations.right
			"back":
				if current_animation != PlayerAnimations.WalkAnimations.back:
					animation_tree.set_passive(PlayerAnimations.WalkAnimations.back)
					current_animation = PlayerAnimations.WalkAnimations.back
			"forward":
				if current_animation != PlayerAnimations.WalkAnimations.forward:
					animation_tree.set_passive(PlayerAnimations.WalkAnimations.forward)
					current_animation = PlayerAnimations.WalkAnimations.forward


func _physics_process(delta: float) -> void:
	# 2d vector = (x, y) where x -1 is forward, 1 is backward, y -1 is right, 1 is left
	var input_vectors := Input.get_vector("move_forward", "move_back", "move_right", "move_left")

	# we normalize the input vector, turn it into a 3d vector, and then apply the rotation so that forward is always in the direction the mesh is facing
	direction = getRotationDirection(input_vectors)
	if knockback_vector != Vector3.ZERO:
		direction = knockback_vector.normalized();

	# dashing sets a cooldown and a timer, and once youve dashed youre stuck dashing until that timer is up
	# and you cannot dash again until the cooldown is over
	var current_speed = speed_adjusted * delta * 100;

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	# move and slide moves the player in the direction of the velocity vector and handles collisions by having the player slide along walls
	move_and_slide()

	# set the appropriate walking animation based on the direction the player is moving
	set_walking_animation()

var rot_y = 0
# if right click is pressed and you're dragging the mouse we'll rotate the player
func _input(event):
	if event is InputEventMouseMotion && Input.is_action_pressed("camera_drag"):
		rot_y = rotation.y - event.relative.x * 0.01

	rotation.y = rot_y

	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 1000.0
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var intersection = space_state.intersect_ray(query)
	if not intersection.is_empty():
		var pos = intersection.position
		model.look_at(Vector3(pos.x, 0, pos.z), Vector3.UP)
		model.rotation.x = 0
		model.rotation.z = 0
