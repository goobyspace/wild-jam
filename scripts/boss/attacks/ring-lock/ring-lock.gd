extends BossAttack

@export var startup_time: float = 0.6
@export var damage = 10
@export var active_time: float = 10.0

@export var cleanup_time: float = 0.5
@export var knockback_duration: float = 0.5
@export var knockback_strength: float = 10.0
@export var lock_movement: bool = true
@export var top_parent: Node3D
@export var ring_lock_node: PackedScene
@export var inner_beam_color: Color = Color(1, 0.2, 0.2, 1)
@export var outer_beam_color: Color = Color(1, 0.3, 0, 0.4)

var rings
func _ready() -> void:
	if ring_lock_node == null:
		push_error("Ring lock node is not set, please assign it in the editor.")
		return
	if not top_parent:
		push_error("Top parent is not set, please assign it in the editor.")
		return
	super._ready()

func set_beam(ring):
	start_blend_animation()
	var omni = ring.find_child("omni")
	var omni_tween = get_tree().create_tween().set_parallel(false)
	omni_tween.tween_property(omni, "light_energy", 1, startup_time / 2)
	await omni_tween.finished
	var beam = ring_lock_node.instantiate()
	ring.add_child(beam)
	var hitbox = beam.find_child("DamageCollider")
	var inner = beam.find_child("inner")
	var inner_material = inner.get_active_material(0)
	var outer_material = beam.find_child("outer").get_active_material(0)
	hitbox.damage = damage
	hitbox.knockback_duration = knockback_duration
	hitbox.knockback_speed = knockback_strength
	hitbox.lock_movement = lock_movement
	hitbox.monitoring = false
	hitbox.connect("body_entered", hitbox._on_body_entered)
	var initial_tween = get_tree().create_tween().set_parallel(true)
	initial_tween.tween_property(beam, "scale", Vector3.ONE, startup_time / 4)
	initial_tween.tween_property(inner_material, "albedo_color", inner_beam_color, startup_time / 4)
	initial_tween.set_parallel(false)
	initial_tween.tween_property(outer_material, "albedo_color", outer_beam_color, startup_time / 4)
	initial_tween.tween_property(outer_material, "emission_energy_multiplier", 1, startup_time / 4)
	await get_tree().create_timer(startup_time).timeout
	hitbox.activate()
	await get_tree().create_timer(active_time).timeout
	hitbox.monitoring = false
	var exit_tween = get_tree().create_tween().set_parallel(true)
	stop_blend_animation()
	exit_tween.tween_property(inner_material, "albedo_color", Color(1, 1, 1, 0), cleanup_time / 4)
	exit_tween.tween_property(beam, "scale", Vector3(0.00001, 0.00001, 0.00001), cleanup_time / 4)
	exit_tween.set_parallel(false)
	exit_tween.tween_property(omni, "light_energy", 0, cleanup_time / 2)
	await exit_tween.finished
	beam.queue_free()


func attack() -> bool:
	var ring_parent = top_parent.get_parent().find_child("rings")
	if ring_parent == null:
		push_error("Ring parent not found, please ensure the hierarchy is correct.")
		return false
	rings = ring_parent.get_children()
	for i in range(rings.size()):
		set_beam(rings[i])
	if wait_for_attack:
		await get_tree().create_timer(startup_time).timeout
		await get_tree().create_timer(active_time).timeout
		await get_tree().create_timer(cleanup_time).timeout

	return true
