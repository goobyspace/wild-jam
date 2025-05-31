extends CharacterBody3D

@export var speed := 800.0
@export var dash_velocity := 20.0
@export var dash_speed := 2000.0
@export var dash_duration := 0.3
@export var dash_speed_duration := 0.5
@export var dash_cooldown := 1.5
@export var collision: CollisionShape3D
@export var model: Node3D
@export var health_bar: Sprite3D
@export var animation_player: AnimationPlayer
@export var idle_animation: Animation
@export var move_animation: Animation

var current_animation: Animation = idle_animation

var camera: Camera3D

var current_speed := 0.0
var dash_speed_timer := 0.0
var dash_timer := 0.0
var dash_cooldown_timer := 0.0

var dash_direction := Vector3.ZERO

var initial_rotation := rotation.y

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	if not collision:
		print("CollisionShape3D is not assigned. Please assign a CollisionShape3D to 'collision' in the inspector.")


func getRotationDirection(originalDirection: Vector2) -> Vector3:
	var vectorThree = Vector3(originalDirection.x, 0, originalDirection.y).normalized()
	return vectorThree \
		.rotated(Vector3(0, 1, 0), rotation.y - initial_rotation) \
		.rotated(Vector3(1, 0, 0), cos(rotation.y) * rotation.x) \
		.rotated(Vector3(0, 0, 1), -sin(rotation.y) * rotation.x)

func setDashCollision():
	collision.disabled = !collision.disabled
	health_bar.visible = !health_bar.visible
		
func handle_dash(direction: Vector3, delta: float) -> Vector3:
	if Input.is_action_just_pressed("move_dash") && dash_cooldown_timer <= 0:
		dash_cooldown_timer = dash_cooldown
		dash_timer = dash_duration
		dash_speed_timer = dash_speed_duration
		setDashCollision() # dashing has an iframe, we hide the health bar when you are immune to damage

		if direction:
			dash_direction = direction; # we capture your current direction when you dash so that you cannot change it mid-dash
		else:
			dash_direction = getRotationDirection(Vector2(-1, 0)) # if you dash without input, we just use the current rotation

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# we give you the speed boost for just a bit longer than the dash lock so that you can still move around a bit after the dash
	if dash_speed_timer > 0:
		dash_speed_timer -= delta
		current_speed = dash_speed * delta;
		if dash_speed_timer <= 0:
			setDashCollision()
	else:
		current_speed = speed * delta;

	if dash_timer > 0:
		dash_timer -= delta
		direction = dash_direction
	return direction

func _physics_process(delta: float) -> void:
	# 2d vector = (x, y) where x -1 is forward, 1 is backward, y -1 is right, 1 is left
	var input_vectors := Input.get_vector("move_forward", "move_back", "move_right", "move_left")

	# we normalize the input vector, turn it into a 3d vector, and then apply the rotation so that forward is always in the direction the mesh is facing
	var direction = getRotationDirection(input_vectors)

	# dashing sets a cooldown and a timer, and once youve dashed youre stuck dashing until that timer is up
	# and you cannot dash again until the cooldown is over
	direction = handle_dash(direction, delta)

	# if the player isnt moving, set the idle animation to play, otherwise do the running animation
	if direction == Vector3.ZERO:
		if current_animation != idle_animation:
			animation_player.change_passive_animation("player/" + idle_animation.resource_name, 1.0)
			current_animation = idle_animation

	else:
		if current_animation != move_animation:
			animation_player.change_passive_animation("player/" + move_animation.resource_name, 2.0)
			current_animation = move_animation


	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	# move and slide moves the player in the direction of the velocity vector and handles collisions by having the player slide along walls

	move_and_slide()

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
