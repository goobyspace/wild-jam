class_name BossAttack extends Node

## Time to wait until the attack starts
@export var delay_time: float = 0.5
## Time until the next attack can start
@export var recovery_time: float = 0.5
## Wait for the attack to finish before starting a new one
@export var wait_for_attack: bool = true
@export var boss_animations: BossAnimations
@export var animation: BossAnimations.Animations

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

func play_animation() -> void:
	if boss_animations:
		boss_animations.execute_animation(animation)

func start_blend_animation() -> void:
	if boss_animations:
		var tween = tree.create_tween()
		tween.tween_method(func(blend): boss_animations.set_blend_animation(animation, blend), 0.0, 1.0, 0.1)

		
func stop_blend_animation() -> void:
	if boss_animations:
		var tween = tree.create_tween()
		tween.tween_method(func(blend): boss_animations.set_blend_animation(animation, blend), 1.0, 0.0, 0.3)
