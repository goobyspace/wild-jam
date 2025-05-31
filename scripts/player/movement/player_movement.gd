extends CharacterBody3D

@export var speed := 800.0
@export var dashVelocity := 20.0
@export var dashSpeed := 2000.0
@export var dashDuration := 0.3
@export var dashSpeedDuration := 0.5
@export var dashCooldown := 1.5
@export var mesh: MeshInstance3D
@export var collision: CollisionShape3D
@export var health_bar: Sprite3D

var currentSpeed := 0.0
var dashSpeedTimer := 0.0
var dashTimer := 0.0
var dashCooldownTimer := 0.0

var dashDirection := Vector3.ZERO

var dashColorChanged := false
var cooldownColorChanged := false

var initial_rotation := rotation.y

var meshMaterial: Material
func _ready() -> void:
	if mesh:
		meshMaterial = mesh.material_override
		if not meshMaterial:
			meshMaterial = mesh.get_surface_override_material(0)
		if not meshMaterial:
			print("No material found on the mesh. Please assign a material to the mesh or set 'mesh' in the inspector.")
	else:
		print("Mesh is not assigned. Please assign a MeshInstance3D to 'mesh' in the inspector.")
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
	if Input.is_action_just_pressed("move_dash") && dashCooldownTimer <= 0:
		dashCooldownTimer = dashCooldown
		dashTimer = dashDuration
		dashSpeedTimer = dashSpeedDuration
		setDashCollision() # dashing has an iframe, we hide the health bar when you are immune to damage

		if direction:
			dashDirection = direction; # we capture your current direction when you dash so that you cannot change it mid-dash
		else:
			dashDirection = getRotationDirection(Vector2(-1, 0)) # if you dash without input, we just use the current rotation

	if dashCooldownTimer > 0:
		dashCooldownTimer -= delta
		if not cooldownColorChanged and not dashSpeedTimer > 0 and meshMaterial:
			meshMaterial.albedo_color = Color(0.5, 0.5, 0.5) # gray color for cooldown
			cooldownColorChanged = true
		elif dashCooldownTimer <= 0 and cooldownColorChanged and meshMaterial:
			cooldownColorChanged = false
			if meshMaterial:
				meshMaterial.albedo_color = Color(1, 1, 1) # reset to white color

	# we give you the speed boost for just a bit longer than the dash lock so that you can still move around a bit after the dash
	if dashSpeedTimer > 0:
		dashSpeedTimer -= delta
		currentSpeed = dashSpeed * delta;
		if not dashColorChanged and meshMaterial:
			meshMaterial.albedo_color = Color(0, 0, 0) # black whilst dashing
			dashColorChanged = true
		elif dashSpeedTimer <= 0 and dashColorChanged:
			setDashCollision()
			dashColorChanged = false
	else:
		currentSpeed = speed * delta;

	if dashTimer > 0:
		dashTimer -= delta
		direction = dashDirection
	return direction

func _physics_process(delta: float) -> void:
	# 2d vector = (x, y) where x -1 is forward, 1 is backward, y -1 is right, 1 is left
	var input_vectors := Input.get_vector("move_forward", "move_back", "move_right", "move_left")
	# we normalize the input vector, turn it into a 3d vector, and then apply the rotation so that forward is always in the direction the mesh is facing
	var direction = getRotationDirection(input_vectors)

	# dashing sets a cooldown and a timer, and once youve dashed youre stuck dashing until that timer is up
	# and you cannot dash again until the cooldown is over
	direction = handle_dash(direction, delta)

	velocity.x = direction.x * currentSpeed
	velocity.z = direction.z * currentSpeed

	# move and slide moves the player in the direction of the velocity vector and handles collisions by having the player slide along walls

	move_and_slide()

var rot_y = 0
# if right click is pressed and you're dragging the mouse we'll rotate the player
func _input(event):
	if event is InputEventMouseMotion && Input.is_action_pressed("camera_drag"):
		rot_y = rotation.y - event.relative.x * 0.01
	rotation.y = rot_y
