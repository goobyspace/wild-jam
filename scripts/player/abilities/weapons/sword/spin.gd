extends PlayerAbility

@export var hits: int = 4
@export var spin_speed: float = 8.0
@export var active_time: float = 0.5
@export var character: Node3D
@export var sound_repeat_count: int = 4

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
	play_repeating_sounds()
	for i in range(hits):
		activate_hitbox()
		await get_tree().create_timer(active_time / hits).timeout
	area_hitbox.monitoring = false
	var tween_end = get_tree().create_tween()
	tween_end.tween_method(func(blend): animation_tree.set_blend_action_animation(PlayerAnimations.ActionAnimations.spin, blend), 1.0, 0.0, 0.3)
	await tween_end.finished
	return true

func play_repeating_sounds() -> void:
	if audio_player and audio_track:
		var sound_interval = active_time / sound_repeat_count

		play_sounds_with_interval(sound_interval, sound_repeat_count)

# Async function that plays sounds at intervals
func play_sounds_with_interval(interval: float, count: int) -> void:
	for i in range(count):
		# Vary volume slightly for each swing to sound more natural
		var vol_variation = randf_range(-2.0, 1.0)
		audio_player.play_audio(audio_track, volume_db + vol_variation, audio_start)
		audio_player.bus = audio_bus
		
		if i < count - 1:  # Don't wait after the last sound
			await get_tree().create_timer(interval).timeout


