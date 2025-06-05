extends PlayerAbility

@export var hits: int = 4
@export var spin_speed: float = 8.0
@export var active_time: float = 0.5
@export var character: Node3D

func _ready() -> void:
	super._ready()
	if area_hitbox == null:
		push_error("Area hitbox is not assigned in the Sword ability.")
		return

	if character == null or not character.has_method("adjust_speed"):
		push_error("Character is not assigned, or does not have the player_movement script.")
		return

	area_hitbox.connect("body_entered", self._on_body_entered)
	area_hitbox.monitoring = false

func _on_use() -> bool:
	var tween_start = get_tree().create_tween()
	tween_start.tween_method(func(blend): animation_tree.set_blend_action_animation(PlayerAnimations.ActionAnimations.spin, blend), 0.0, 1.0, 0.1)
	tween_start.tween_method(func(speed): character.adjust_speed(speed, active_time), character.speed, spin_speed, 0.1)
	for i in range(hits):
		activate_hitbox()
		await get_tree().create_timer(active_time / hits).timeout
	area_hitbox.monitoring = false
	var tween_end = get_tree().create_tween()
	tween_end.tween_method(func(blend): animation_tree.set_blend_action_animation(PlayerAnimations.ActionAnimations.spin, blend), 1.0, 0.0, 0.3)
	await tween_end.finished
	return true
