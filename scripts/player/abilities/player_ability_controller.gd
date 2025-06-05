extends Node

@export var global_cooldown: float = 0.5
@export var abilities: Array[PlayerAbility] = []

var _cooldown_timer: float = 0.0

signal ability_used(ability: PlayerAbility, gcd: float)

func _ready() -> void:
	if abilities.is_empty():
		push_error("No abilities assigned in the PlayerAbilityController.")
		return

func use_ability(ability: PlayerAbility) -> void:
	if not ability or ability.is_on_cooldown:
		return
	_cooldown_timer = global_cooldown
	ability_used.emit(ability, global_cooldown)
	ability.use()

func _process(_delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= _delta
		return

func _unhandled_input(event: InputEvent) -> void:
	for ability in abilities:
		if _cooldown_timer > 0.0:
			return
		if InputMap.event_is_action(event, ability.keybind.action):
			use_ability(ability)
