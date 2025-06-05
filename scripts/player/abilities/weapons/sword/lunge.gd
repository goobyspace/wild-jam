extends PlayerAbility

@export var active_time: float = 0.5
@export var lock_time: float = 0.7
@export var character: Node3D
@export var lightning_bolt_sound: AudioStream

var lightning_sound = preload("res://assets/sounds/lightningbolt.ogg")
var sword_sound = preload("res://assets/sounds/swordattack.wav")

func _ready() -> void:
	if area_hitbox == null:
		push_error("Area hitbox is not assigned in the Sword ability.")
		return

	if character == null or not character.has_method("lock_movement"):
		push_error("Character is not assigned, or does not have the player_movement script.")
		return

	area_hitbox.connect("body_entered", self._on_body_entered)
	area_hitbox.monitoring = false

func _on_body_entered(body: Node) -> void:
	var health_node = body.find_child("enemy_health")
	if health_node and health_node.has_method("take_damage"):
		health_node.take_damage(damage)

func _on_use() -> bool:
	play_animation()
	play_combined_audio()
	activate_hitbox()
	character.lock_movement(lock_time)
	await get_tree().create_timer(active_time).timeout
	area_hitbox.monitoring = false
	await get_tree().create_timer(lock_time - active_time).timeout
	return true

func play_combined_audio() -> void:
	if audio_player:
		# First play the main audio track (sword sound)
		if audio_track:
			print("Playing main audio track")
			audio_player.play_audio(audio_track, volume_db, audio_start)
			audio_player.bus = audio_bus
		
		# Short delay
		await get_tree().create_timer(0.20).timeout
		
		# Then play the lightning sound
		if lightning_sound:
			print("Playing lightning sound")
			audio_player.play_audio(lightning_sound, volume_db - 2.0, 0.0)
			audio_player.bus = audio_bus
	



