class_name PlayerAttack extends Node

@export var attack_cooldown: float = 0.5

var is_on_cooldown: bool = false

func attack() -> void:
	if is_on_cooldown:
		return

	is_on_cooldown = true
	on_attack()
	await get_tree().create_timer(attack_cooldown).timeout
	is_on_cooldown = false

func on_attack():
	await get_tree().create_timer(0).timeout
	return true