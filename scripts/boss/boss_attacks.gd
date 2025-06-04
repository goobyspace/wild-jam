class_name BossAttack extends Node

@export var delay_time: float = 0.5 # Time to wait until the attack can start
@export var recovery_time: float = 0.5 # Time to wait until the next attack can start'
@export var audio_track: AudioStream
@export var audio_player: AudioStreamPlayer3D
@export var volume_db: float = 0.0
@export var audio_start: float = 0.0
var tree: SceneTree

func _ready() -> void:
	tree = get_tree()

func on_attack() -> bool:
	await tree.create_timer(delay_time).timeout
	var result = await attack()
	if audio_track and audio_player:
		audio_player.play_audio(audio_track, volume_db)
		
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
