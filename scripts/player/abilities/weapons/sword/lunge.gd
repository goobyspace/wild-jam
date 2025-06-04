extends PlayerAbility

@export var area_hitbox: Area3D
@export var damage: int = 20
@export var active_time: float = 0.5
@export var lock_time: float = 0.7
@export var character: Node3D

func _ready() -> void:
	if area_hitbox == null:
		push_error("Area hitbox is not assigned in the Sword ability.")
		return

	if character == null or not character.has_method("lock_movement"):
		push_error("Character is not assigned, or does not have the player_movement script.")
		return

	area_hitbox.connect("body_entered", self._on_body_entered)
	area_hitbox.monitoring = false

func _on_body_entered(body: Node) -> void:
	var health_node = body.find_child("enemy_health")
	if health_node and health_node.has_method("take_damage"):
		health_node.take_damage(damage)

func _on_use() -> bool:
	play_animation()
	area_hitbox.monitoring = true
	character.lock_movement(lock_time)
	await get_tree().create_timer(active_time).timeout
	area_hitbox.monitoring = false
	await get_tree().create_timer(lock_time - active_time).timeout
	return true
