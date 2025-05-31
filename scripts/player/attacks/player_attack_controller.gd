extends Node

@export var mainAttack: PlayerAttack
@export var primaryAttack: PlayerAttack
@export var secondaryAttack: PlayerAttack
@export var spellPrimary: PlayerAttack
@export var spellSecondary: PlayerAttack

func _ready() -> void:
	if mainAttack == null or primaryAttack == null or secondaryAttack == null or spellPrimary == null or spellSecondary == null:
		push_error("One or more attacks are not assigned in the PlayerAttackController.")
		return

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack_normal"):
		mainAttack.attack()
	elif Input.is_action_just_pressed("attack_primary"):
		primaryAttack.attack()
	elif Input.is_action_just_pressed("attack_secondary"):
		secondaryAttack.attack()
	elif Input.is_action_just_pressed("spell_one"):
		spellPrimary.attack()
	elif Input.is_action_just_pressed("spell_two"):
		spellSecondary.attack()
