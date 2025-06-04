extends CharacterBody3D

@export var speed := 4.0

@export var model: Node3D
@export var animation_tree: AnimationTree
@export var _rotation_speed: float = TAU * 4

var current_animation := PlayerAnimations.WalkAnimations.idle
var camera: Camera3D
var speed_adjusted := speed
var initial_rotation := rotation.y
var knockback_vectors: Array[knockback] = []
var direction := Vector3.ZERO
var movement_lock := 0.0
var model_lock := false
var look_at_directon := Vector3.ZERO
var _theta := 0.0
var mouse_raycast: Vector3 = Vector3.ZERO

func _ready() -> void:
	camera = get_viewport().get_camera_3d()

func getRotationDirection(originalDirection: Vector2) -> Vector3:
	var vectorThree = Vector3(originalDirection.x, 0, originalDirection.y).normalized()
	return vectorThree \
		.rotated(Vector3(0, 1, 0), rotation.y - initial_rotation) \
		.rotated(Vector3(1, 0, 0), cos(rotation.y) * rotation.x) \
		.rotated(Vector3(0, 0, 1), -sin(rotation.y) * rotation.x)


func set_direction(knockback_direction: Vector3, knockback_speed: float, duration: float, lock: bool = false) -> void:
	if knockback_direction == Vector3.ZERO:
		knockback_direction = direction
	knockback_vectors.append(knockback.new(knockback_direction, knockback_speed, duration, lock))

func lock_movement(lock_duration: float) -> void:
	movement_lock += lock_duration


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
	var input_vectors := Input.get_vector("move_right", "move_left", "move_back", "move_forward")

	# we normalize the input vector, turn it into a 3d vector, and then apply the rotation so that forward is always in the direction the mesh is facing
	direction = getRotationDirection(input_vectors)
	var current_speed = speed_adjusted * delta * 100;
	direction = direction * current_speed

	if movement_lock > 0:
		movement_lock -= delta
		direction = Vector3.ZERO
	
	model_lock = false
	knockback_vectors = knockback_vectors.filter(func(kb: knockback) -> bool:
		direction += kb.knockback_vector.normalized() * kb.knockback_speed
		kb.knockback_duration -= delta
		if kb.lock_direction:
			model_lock = true
			# https://www.youtube.com/watch?v=NrvIuBu3-8I
			_theta = wrapf(atan2(-kb.knockback_vector.x, -kb.knockback_vector.z) - model.rotation.y, -PI, PI)
			model.rotation.y += clamp(_rotation_speed * delta, 0, abs(_theta)) * sign(_theta)

		if kb.knockback_duration <= 0:
			return false
		else:
			return true
	)

	# we rotate the player here so that the player rotates back instantly when a knockback lock is over
	# otherwise the player will stay facing the direction of the knockback until the next mouse input
	if not model_lock and mouse_raycast != Vector3.ZERO:
		model.look_at(mouse_raycast, Vector3.UP)
		
	model.rotation.x = 0
	model.rotation.z = 0


	velocity.x = direction.x;
	velocity.z = direction.z;

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

	# we get the mouse position compared to the center of the screen to rotate the player model in _physics_process
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * 100000
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, end, 0b00010000_00000000_00000000_00001000)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	if result.position:
		mouse_raycast = result.position
