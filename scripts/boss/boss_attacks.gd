class_name BossAttack extends Node

@export var delay_time: float = 0.5 # Time to wait until the attack can start
@export var recovery_time: float = 0.5 # Time to wait until the next attack can start'
var tree: SceneTree

func _ready() -> void:
	tree = get_tree()

func on_attack() -> bool:
	await tree.create_timer(delay_time).timeout #
	var result = await attack()
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
