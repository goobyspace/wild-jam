extends Area3D
@export var damage_amount: int = 10
# Called when the node enters the scene tree for the first time.
func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.find_child("health").take_damage(damage_amount)
