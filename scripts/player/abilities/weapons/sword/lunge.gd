extends PlayerAbility

@export var active_time: float = 0.5
@export var lock_time: float = 0.7
@export var character: Node3D
@export var lightning_bolt: MeshInstance3D

var color: Color = Color(0, 0.6, 1, 1)
var transparent: Color = Color(0, 0.6, 1, 0)
var material: StandardMaterial3D

func _ready() -> void:
	if area_hitbox == null:
		push_error("Area hitbox is not assigned in the Sword ability.")
		return

	if character == null or not character.has_method("lock_movement"):
		push_error("Character is not assigned, or does not have the player_movement script.")
		return

	area_hitbox.connect("body_entered", self._on_body_entered)
	area_hitbox.monitoring = false
	material = lightning_bolt.get_surface_override_material(0) as StandardMaterial3D

func _on_body_entered(body: Node) -> void:
	var health_node = body.find_child("enemy_health")
	if health_node and health_node.has_method("take_damage"):
		health_node.take_damage(damage)

func _on_use() -> bool:
	play_animation()
	activate_hitbox()
	character.lock_movement(lock_time)
	var tween = get_tree().create_tween()
	tween.tween_property(material, "albedo_color", transparent, active_time / 2)
	tween.tween_property(material, "albedo_color", color, active_time / 4)
	await get_tree().create_timer(active_time).timeout
	var out_tween = get_tree().create_tween()
	out_tween.tween_property(material, "albedo_color", transparent, active_time / 2)
	area_hitbox.monitoring = false
	await get_tree().create_timer(lock_time - active_time).timeout
	return true
