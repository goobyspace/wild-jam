extends Node

@export var cooldown_bars: Control
@export var cooldown_button: PackedScene

@export var player: CharacterBody3D

var abilities: Array[PlayerAbility] = []

func _on_ability_used(ability: PlayerAbility) -> void:
	# Handle the ability used event, e.g., update UI or trigger effects
	print("Ability used:", ability.name)

func _ready() -> void:
	abilities = player.find_child("attack_controller").abilities

	for ability in abilities:
		var button = cooldown_button.instantiate()
		cooldown_bars.add_child(button)
		button.connect("ability_used", _on_ability_used)
