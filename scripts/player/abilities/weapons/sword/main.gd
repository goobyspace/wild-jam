extends PlayerAbility

@export var active_time: float = 0.5

func _ready() -> void:
	if area_hitbox == null:
		push_error("Area hitbox is not assigned in the Sword ability.")
		return

	area_hitbox.connect("body_entered", self._on_body_entered)
	area_hitbox.monitoring = false

func _on_body_entered(body: Node) -> void:
	var health_node = body.find_child("enemy_health")
	if health_node and health_node.has_method("take_damage"):
		health_node.take_damage(damage)

func _on_use() -> bool:
	if audio_player and audio_track:
		audio_player.play_audio(audio_track, volume_db, audio_start)
		audio_player.bus = audio_bus
	play_animation()
	activate_hitbox()
	await get_tree().create_timer(active_time).timeout
	area_hitbox.monitoring = false
	return true
