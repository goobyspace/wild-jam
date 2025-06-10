extends BossAttack

@export var active_delay: float = 0.5
@export var rotation_speed: float = 1.0
@export var damage: int = 5
@export var active_time := 5.0
@export var amount: int = 3
@export var beam_node: PackedScene
@export var inner_beam_color: Color = Color(0.2, 1, 0.2, 1)
@export var audio_fade_duration: float = 0.9

var hitboxes = []

func _ready() -> void:
	super._ready()
	play_in_parent = false
	if beam_node == null:
		push_error("Beam node is not set, please assign it in the editor.")
		return

func spawn_beam(initial_rotation: Vector3) -> void:
	start_blend_animation()
	var beam = beam_node.instantiate()
	var hitbox = beam.find_child("DamageCollider")
	var inner_material = beam.find_child("inner").get_active_material(0)
	var outer = beam.find_child("outer")
	self.add_child(beam)
	beam.rotation = initial_rotation
	var initial_tween = get_tree().create_tween()
	initial_tween.tween_property(inner_material, "albedo_color", inner_beam_color, active_delay / 2)
	initial_tween.tween_property(outer, "scale", Vector3.ONE, active_delay / 2)
	await initial_tween.finished
	hitbox.activate()
	hitbox.damage = damage
	hitbox.connect("body_entered", hitbox._on_body_entered)
	hitboxes.append(hitbox)
	var tween = get_tree().create_tween()
	tween.tween_property(beam, "rotation", Vector3(beam.rotation.x, beam.rotation.y - PI * rotation_speed, beam.rotation.z), active_time)
	await tween.finished
	hitbox.monitoring = false
	var exit_tween = get_tree().create_tween().set_parallel(true)
	exit_tween.tween_property(inner_material, "albedo_color", Color(1, 1, 1, 0), active_delay / 2)
	exit_tween.tween_property(outer, "scale", Vector3.ZERO, active_delay / 2)
	stop_blend_animation()
	await exit_tween.finished
	beam.queue_free()

func attack() -> bool:
	for i in range(amount):
		var starting_rotation = Vector3(0, i * (PI * 2 / amount), 0)
		spawn_beam(starting_rotation)
	do_damage()
	do_audio()
	if wait_for_attack:
		await get_tree().create_timer(active_delay + active_time).timeout
	return true

func do_audio() -> void:
	if audio_player and audio_track:
		audio_track.loop = true
		audio_player.play_audio(audio_track, volume_db, audio_start)
		var original_volume = audio_player.volume_db
		await get_tree().create_timer(active_time - audio_fade_duration).timeout
		var audio_tween = get_tree().create_tween()
		audio_player.autoplay = true
		audio_tween.tween_property(audio_player, "volume_db", -80.0, audio_fade_duration)
		audio_tween.tween_callback(
			func():
				audio_player.stop_audio()
		)
		# Reset volume for future sounds
		audio_tween.tween_property(audio_player, "volume_db", original_volume, 0.01)

func do_damage() -> void:
	await get_tree().create_timer(active_delay + active_time).timeout
	var player_found = false
	for hitbox in hitboxes:
		hitbox.monitoring = false
		if hitbox.player:
			player_found = true
	if not player_found:
		hitboxes[0].do_damage()
	hitboxes.clear()
