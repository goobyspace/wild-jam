extends Node

@export var global_cooldown: float = 0.5
@export var mainAttack: PlayerAbility
@export var primaryAttack: PlayerAbility
@export var secondaryAttack: PlayerAbility
@export var spellPrimary: PlayerAbility
@export var spellSecondary: PlayerAbility
@export var dash: PlayerAbility

var _cooldown_timer: float = 0.0
var abilities: Array[PlayerAbility] = [mainAttack, primaryAttack, secondaryAttack, spellPrimary, spellSecondary, dash]

func _ready() -> void:
	if dash == null or mainAttack == null or primaryAttack == null or secondaryAttack == null or spellPrimary == null or spellSecondary == null:
		push_error("One or more abilities are not assigned in the PlayerAbilityController.")
		return

func use_ability(ability: PlayerAbility) -> void:
	if ability.is_on_cooldown:
		return
	_cooldown_timer = global_cooldown
	ability.use()

func _process(_delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= _delta
		return
	if Input.is_action_just_pressed("move_dash"): use_ability(dash)
	elif Input.is_action_just_pressed("attack_normal"): use_ability(mainAttack)
	elif Input.is_action_just_pressed("attack_primary"): use_ability(primaryAttack)
	elif Input.is_action_just_pressed("attack_secondary"): use_ability(secondaryAttack)
	elif Input.is_action_just_pressed("spell_one"): use_ability(spellPrimary)
	elif Input.is_action_just_pressed("spell_two"): use_ability(spellSecondary)
