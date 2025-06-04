extends Node

@export var cooldown_bars: Control
@export var cooldown_button: PackedScene

@export var player: CharacterBody3D

func _ready() -> void:
	var attack_controller = player.find_child("attack_controller")
	var abilities = attack_controller.abilities

	for ability in abilities:
		var button = cooldown_button.instantiate()
		cooldown_bars.add_child(button)
		button.set_ability(ability)
		ability.connect("ability_used", button._on_ability_used)
		attack_controller.connect("ability_used", button._any_ability_used)
