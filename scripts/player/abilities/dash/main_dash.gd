extends PlayerAbility

@export var dash_speed := 12
@export var dash_duration := 0.3
@export var dash_speed_duration := 0.2
@export var health_bar: Sprite3D
@export var character: CharacterBody3D

var hp: Node

var dash_speed_timer := 0.0
var dash_timer := 0.0
var dash_cooldown_timer := 0.0

var dash_direction := Vector3.ZERO

func _ready() -> void:
	hp = get_tree().root.get_node("Main/Player/player_health");
	

func setDashCollision():
	hp.block_taking_damage = !hp.block_taking_damage
	health_bar.visible = !health_bar.visible

func _on_use() -> bool:
	play_animation()
	setDashCollision()
	character.set_direction(dash_direction, dash_speed, dash_duration, true)
	await get_tree().create_timer(dash_duration).timeout
	character.adjust_speed(dash_speed, dash_speed_duration)
	setDashCollision()
	return true
