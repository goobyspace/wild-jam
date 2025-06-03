class_name PlayerAbility extends Node

@export var ability_cooldown: float = 1.0
@export var animation_tree: AnimationTree
@export var animation: PlayerAnimations.ActionAnimations

var is_on_cooldown: bool = false

func use() -> void:
	if is_on_cooldown:
		return

	is_on_cooldown = true
	_on_use()
	await get_tree().create_timer(ability_cooldown).timeout
	is_on_cooldown = false

func _on_use(): # override this method in subclasses to make attacks
	await get_tree().create_timer(0).timeout
	return true

func play_animation() -> void:
	if animation_tree:
		animation_tree.execute_action_animation(animation)
