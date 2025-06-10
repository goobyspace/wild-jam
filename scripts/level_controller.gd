extends Node
@export var main_scene: PackedScene
@export var level_scene: PackedScene
@export var end_screen: PackedScene

@export var player_characters: Array[PackedScene] = []

var selected_player: int = 0

var current_scene: Node = null
func change_level_scene(scene: PackedScene, initial_position: Vector3 = Vector3.ZERO) -> void:
	current_scene.queue_free()
	current_scene = scene.instantiate()
	var player = player_characters[selected_player].instantiate()
	current_scene.add_child(player)
	player.global_position = initial_position
	add_child(current_scene)
	var enemy_hp = current_scene.get_node("Enemy/enemy_health")
	if enemy_hp:
		enemy_hp.connect("health_depleted", _victory)
	var player_hp = current_scene.get_node("Player/player_health")
	if player_hp:
		player_hp.connect("health_depleted", _defeat)


func _ready() -> void:
	current_scene = main_scene.instantiate()
	add_child(current_scene)

func _victory() -> void:
	current_scene.queue_free()
	current_scene = end_screen.instantiate()
	add_child(current_scene)
	current_scene.on_victory()

func _defeat() -> void:
	current_scene.queue_free()
	current_scene = end_screen.instantiate()
	add_child(current_scene)
	current_scene.on_defeat()
