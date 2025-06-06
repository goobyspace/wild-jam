extends PlayerAbility

@export var character: Node3D
@export var bolt: PackedScene
@export var startup_time: float = 0.2
@export var travel_time: float = 0.5

func _ready() -> void:
	super._ready()

	if character == null or not character.has_method("adjust_speed"):
		push_error("Character is not assigned, or does not have the player_movement script.")
		return

	if bolt == null:
		push_error("Thunder mesh is not assigned in the Thunderstrike ability.")
		return

func _on_body_entered(body: Node) -> void:
	var health_node = body.find_child("enemy_health")
	if health_node and health_node.has_method("take_damage"):
		health_node.take_damage(damage)

func _on_use() -> bool:
	play_animation()
	if audio_player and audio_track:
		audio_player.play_audio(audio_track, volume_db, audio_start)
		audio_player.bus = audio_bus
	character.adjust_speed(character.speed / 2, startup_time)

	await get_tree().create_timer(startup_time).timeout
	var new_bolt = bolt.instantiate()
	character.add_sibling(new_bolt)
	area_hitbox = new_bolt.get_node("Area3D")
	area_hitbox.connect("body_entered", self._on_body_entered)
	activate_hitbox()

	new_bolt.position = character.position
	new_bolt.look_at(character.mouse_raycast, Vector3.UP)
	new_bolt.rotation.y = new_bolt.rotation.y - PI
	var tween = get_tree().create_tween()
	tween.tween_property(new_bolt, "position", new_bolt.global_basis.z * 100, travel_time)
	await tween.finished
	area_hitbox.monitoring = false
	new_bolt.queue_free()
	return true
