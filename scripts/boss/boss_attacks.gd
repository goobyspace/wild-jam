class_name BossAttack extends Node

## Time to wait until the attack starts
@export var delay_time: float = 0.5
## Time until the next attack can start
@export var recovery_time: float = 0.5
## Wait for the attack to finish before starting a new one
@export var wait_for_attack: bool = true
@export var boss_animations: BossAnimations
@export var animation: BossAnimations.Animations
@export var audio_track: AudioStream
@export var audio_player: Node
@export var volume_db: float = 0.0
@export var audio_start: float = 0.0
@export var audio_bus: String = "SFX"

var tree: SceneTree
var play_in_parent: bool = true # If true, the audio will be played in the boss_attacks


func _ready() -> void:
	tree = get_tree()
	play_in_parent = true #Default to true to avoid audio issues when set to false during another attack

func on_attack() -> bool:
	await tree.create_timer(delay_time).timeout
	
	if play_in_parent == true:
		play_attack_audio()

	var result = await attack()
	await tree.create_timer(recovery_time).timeout
	return result

func play_attack_audio() -> void:
	if audio_player and audio_track:
		audio_player.play_audio(audio_track, volume_db, audio_start)
		audio_player.bus = audio_bus

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
