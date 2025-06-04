class_name DamageCollider extends Area3D
@export var damage: int = 10
var knockback_duration: float
var knockback_speed: float
var lock_movement: bool

func check_node(body: Node) -> void:
	var health_node = body.find_child("player_health")
	if health_node and health_node.has_method("take_damage"):
		body.find_child("player_health").take_damage(damage)
		if knockback_duration != null and knockback_speed != null:
			body.set_direction(position.direction_to(body.global_transform.origin), knockback_speed, knockback_duration)

func activate() -> void:
	monitoring = true
	var nodes = get_overlapping_bodies()
	if nodes.size() > 0:
		for body in nodes:
			check_node(body)


func _on_body_entered(body: Node) -> void:
	check_node(body)
