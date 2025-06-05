class_name PlayerAbility extends Node

@export var ability_cooldown: float = 1.0
@export var animation_tree: AnimationTree
@export var animation: PlayerAnimations.ActionAnimations
@export var icon: Texture
@export var keybind: InputEventAction
@export var area_hitbox: Area3D
@export var damage: int = 3
@export var audio_track: AudioStream
@export var audio_player: UniversalAudioPlayer
@export var volume_db: float = 0.0
@export var audio_start: float = 0.0
@export var audio_bus: String = "SFX"

signal ability_used(ability: PlayerAbility)

var is_on_cooldown: bool = false

func _ready() -> void:
	if animation_tree == null:
		push_error("Animation tree is not assigned in the PlayerAbility.")
		return

	if animation == null:
		push_error("Animation is not assigned in the PlayerAbility.")
		return
		
func use() -> void:
	if is_on_cooldown:
		return

	ability_used.emit(self)
	is_on_cooldown = true
	_on_use()
	await get_tree().create_timer(ability_cooldown).timeout
	is_on_cooldown = false

func _on_use(): # override this method in subclasses to make attacks
	await get_tree().create_timer(0).timeout
	return true

func play_ability_audio() -> void:
	if audio_player and audio_track:
		audio_player.play_audio(audio_track, volume_db, audio_start)
		audio_player.bus = audio_bus

func play_animation() -> void:
	if animation_tree:
		animation_tree.execute_action_animation(animation)

func check_node(body: Node) -> void:
	var health_node = body.find_child("enemy_health")
	if health_node and health_node.has_method("take_damage"):
		health_node.take_damage(damage)

func _on_body_entered(body: Node) -> void:
	check_node(body)

func activate_hitbox():
	if area_hitbox:
		area_hitbox.monitoring = true
		var nodes = area_hitbox.get_overlapping_bodies()
		if nodes.size() > 0:
			for body in nodes:
				check_node(body)