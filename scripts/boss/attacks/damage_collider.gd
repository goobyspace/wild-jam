class_name DamageCollider extends Area3D
@export var damage: int = 10

func _on_body_entered(body: Node) -> void:
	var health_node = body.find_child("player_health")
	if health_node and health_node.has_method("take_damage"):
		body.find_child("player_health").take_damage(damage)
		body.set_direction(position.direction_to(body.global_transform.origin), 10, 0.5)
