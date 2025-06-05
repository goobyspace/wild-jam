extends Node

@export var intro_attacks: Array[AttackGrouper] = []
@export var attacks: Array[AttackGrouper] = []
var unpacked_intro_attacks: Array[BossAttack] = []
var unpacked_attacks: Array[BossAttack] = []
var current_attack_index: int = 0
var tree: SceneTree
var attack_ongoing: bool = false
var intro_attacks_done: bool = false

func next_attack() -> void:
	attack_ongoing = true
	await execute_attack(unpacked_attacks[current_attack_index])
	if current_attack_index < unpacked_attacks.size() - 1:
		current_attack_index += 1
	else:
		current_attack_index = 0
	attack_ongoing = false

func next_intro_attack() -> void:
	if unpacked_intro_attacks.size() == 0:
		intro_attacks_done = true
		return

	attack_ongoing = true
	await execute_attack(unpacked_intro_attacks[current_attack_index])
	if current_attack_index < unpacked_intro_attacks.size() - 1:
		current_attack_index += 1
	else:
		current_attack_index = 0
		intro_attacks_done = true
	attack_ongoing = false

func execute_attack(attack: BossAttack):
	if attack == null or not attack.name:
		push_error("Invalid attack provided to execute_attack. Remember to assign an attack in the inspector.")
		return
		
	await attack.on_attack()
	attack.on_finish()


func _process(_delta: float) -> void:
	if not attack_ongoing:
		if not intro_attacks_done:
			next_intro_attack()
		else:
			next_attack()

func _ready() -> void:
	for total_intro_attacks in intro_attacks:
		unpacked_intro_attacks.append_array(total_intro_attacks.attacks)
	for total_attacks in attacks:
		unpacked_attacks.append_array(total_attacks.attacks)
	if attacks.size() == 0:
		return
