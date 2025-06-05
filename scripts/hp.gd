extends Node

signal health_changed(new_health: int)
signal health_depleted()

var block_taking_damage: bool = false

@export var maxHealth: int = 100
var currentHealth: int = 100

func take_damage(amount: int) -> void:
	if block_taking_damage:
		return
	currentHealth -= amount
	emit_signal("health_changed", currentHealth)

	if currentHealth < 0:
		currentHealth = 0
		emit_signal("health_depleted")
