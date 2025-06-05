extends PlayerAbility

@export var active_time: float = 0.5
@export var stun_time: float = 1.2
@export var character: Node3D
@export var thunder: MeshInstance3D
@export var startup_time: float = 0.2
@export var fadeout_time: float = 0.5
var omni_light: OmniLight3D
var material: StandardMaterial3D
var thunder_color: Color;
var thunder_scale: Vector3;

var light_energy: float;
var light_size: float;

const small_scale = Vector3(0.01, 0.01, 0.01)
const blank = Color(1, 1, 1, 0)
const start_energy = 0.0
const start_size = 0.0

func _ready() -> void:
	super._ready()
	if area_hitbox == null:
		push_error("Area hitbox is not assigned in the Sword ability.")
		return

	if character == null or not character.has_method("lock_movement"):
		push_error("Character is not assigned, or does not have the player_movement script.")
		return

	if thunder == null:
		push_error("Thunder mesh is not assigned in the Thunderstrike ability.")
		return
	material = thunder.get_surface_override_material(0) as StandardMaterial3D
	omni_light = thunder.get_node("OmniLight3D")
	light_energy = omni_light.light_energy
	light_size = omni_light.light_size
	thunder_color = material.albedo_color
	thunder_scale = thunder.scale

	material.albedo_color = blank
	thunder.scale = small_scale
	omni_light.light_energy = start_energy
	omni_light.light_size = start_size

	area_hitbox.connect("body_entered", self._on_body_entered)
	area_hitbox.monitoring = false

func _on_body_entered(body: Node) -> void:
	var health_node = body.find_child("enemy_health")
	if health_node and health_node.has_method("take_damage"):
		health_node.take_damage(damage)

func _on_use() -> bool:
	activate_hitbox()
	if audio_player and audio_track:
		audio_player.play_audio(audio_track, volume_db, audio_start)
		audio_player.bus = audio_bus
	play_animation()
	character.lock_movement(stun_time)
	material.albedo_color = thunder_color
	var tween_start = get_tree().create_tween().set_parallel(true)
	tween_start.tween_property(omni_light, "light_energy", light_energy, startup_time)
	tween_start.tween_property(omni_light, "light_size", light_size, startup_time)
	tween_start.set_parallel(false)
	tween_start.tween_property(thunder, "scale", thunder_scale, 0.2)
	await get_tree().create_timer(active_time).timeout
	area_hitbox.monitoring = false
	var tween_end = get_tree().create_tween().set_parallel(true)
	tween_end.tween_property(material, "albedo_color", blank, fadeout_time)
	tween_end.tween_property(omni_light, "light_size", start_energy, fadeout_time)
	tween_end.tween_property(omni_light, "light_energy", start_energy, fadeout_time)
	tween_end.set_parallel(false)
	await get_tree().create_timer(stun_time - active_time).timeout
	thunder.scale = small_scale
	return true
