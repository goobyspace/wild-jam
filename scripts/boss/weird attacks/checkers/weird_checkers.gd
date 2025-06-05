extends BossAttack

@export_group("Grid Attack")
## Imagine if the map is divided into a 3x3 grid, click the cells that will spawn the attack
@export var grid: Array[WeirdCheckerGrid] = []
@export_range(0, 100, 1) var repeat: int = 0
@export var startup: float = 0.5
@export var active_time: float = 1.0
@export var cleanup_time: float = 0.5
@export var damage: int = 5
@export_group("Scenes")
@export var checker_scene: PackedScene
@export var top_parent: Node3D

var parent: Node3D
var depth = 44.0
var width = 42.0
var hitboxes = []

func _ready():
	super._ready()
	if not checker_scene:
		push_error("Checker scene is not set.")
		return

	if grid.size() == 0:
		push_error("Grid is empty, please add at least one WeirdCheckerGrid resource.")
		return

	parent = top_parent.get_parent()

func get_checkers():
	for _i in repeat:
		for i in range(grid.size()):
			play_animation()
			var checker = grid[i].grid
			# originally i tried doing this dynamically but its only 9 values so fuck it
			if checker["top_left"]:
				spawn_checker(checker.top_left, Vector3(width / 2, 0, depth / 2))
			if checker["top_center"]:
				spawn_checker(checker.top_center, Vector3(width / 6, 0, depth / 2))
			if checker["top_right"]:
				spawn_checker(checker.top_right, Vector3(-width / 6, 0, depth / 2))
			if checker["middle_left"]:
				spawn_checker(checker.middle_left, Vector3(width / 2, 0, depth / 6))
			if checker["middle_center"]:
				spawn_checker(checker.middle_center, Vector3(width / 6, 0, depth / 6))
			if checker["middle_right"]:
				spawn_checker(checker.middle_right, Vector3(-width / 6, 0, depth / 6))
			if checker["bottom_left"]:
				spawn_checker(checker.bottom_left, Vector3(width / 2, 0, -depth / 6))
			if checker["bottom_center"]:
				spawn_checker(checker.bottom_center, Vector3(width / 6, 0, -depth / 6))
			if checker["bottom_right"]:
				spawn_checker(checker.bottom_right, Vector3(-width / 6, 0, -depth / 6))

			await get_tree().create_timer(startup).timeout
			await get_tree().create_timer(active_time).timeout
			var player_found = false
			for hitbox in hitboxes:
				if hitbox.player:
					player_found = true
			if not player_found:
				hitboxes[0].do_damage()
			hitboxes.clear()
			await get_tree().create_timer(cleanup_time).timeout


func spawn_checker(checker: bool, position: Vector3) -> void:
	if checker:
		var checker_instance = checker_scene.instantiate()
		checker_instance.scale = Vector3(width / 3, 1, depth / 3)
		var initial_position = Vector3(-width / 6, 0.3, -depth / 6)
		checker_instance.position = initial_position + position
		parent.add_child(checker_instance)
		var checker_mesh = checker_instance.get_node("mesh")
		checker_mesh.scale = Vector3(0.001, 0.001, 0.001)
		var tween = get_tree().create_tween().set_parallel(true)
		var material = checker_mesh.get_active_material(0)
		material.albedo_color = Color(1, 1, 1, 0) # Start with transparent white
		tween.tween_property(material, "albedo_color", Color(1, 0, 0, 0.8), startup)
		tween.tween_property(checker_mesh, "scale", Vector3.ONE, startup)
		await get_tree().create_timer(startup).timeout
		var hitbox = checker_instance.find_child("DamageCollider")
		hitboxes.append(hitbox)
		hitbox.damage = damage
		hitbox.connect("body_entered", hitbox._on_body_entered)
		hitbox.activate()
		await get_tree().create_timer(active_time).timeout
		hitbox.monitoring = false
		tween = get_tree().create_tween()
		tween.tween_property(material, "albedo_color", Color(1, 1, 1, 0), cleanup_time)
		await get_tree().create_timer(cleanup_time).timeout
		checker_instance.queue_free()

func attack():
	get_checkers()
	if wait_for_attack:
		await get_tree().create_timer((startup + active_time + cleanup_time) * grid.size() * (repeat + 1)).timeout
	return true
