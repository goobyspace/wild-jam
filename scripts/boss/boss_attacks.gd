class_name BossAttack extends Node

## Time to wait until the attack starts
@export var delay_time: float = 0.5
## Time until the next attack can start
@export var recovery_time: float = 0.5
## Wait for the attack to finish before starting a new one
@export var wait_for_attack: bool = true

var tree: SceneTree

func _ready() -> void:
	tree = get_tree()

func on_attack() -> bool:
	await tree.create_timer(delay_time).timeout
	var result = await attack()
	await tree.create_timer(recovery_time).timeout
	return result

func on_finish() -> void:
	return cleanup()

#this function should be overwritten by subclasses
func attack() -> bool:
	await tree.create_timer(0).timeout
	return true

#this function should be overwritten by subclasses
func cleanup() -> void:
	return
