extends Node

@export var attacks: Array[BossAttack] = []
var current_attack_index: int = 0
var tree: SceneTree
var attack_ongoing: bool = false

func next_attack() -> void:
	attack_ongoing = true
	await execute_attack(attacks[current_attack_index])
	if current_attack_index < attacks.size() - 1:
		current_attack_index += 1
	else:
		current_attack_index = 0
	attack_ongoing = false

func execute_attack(attack: BossAttack):
	if attack == null or not attack.name:
		push_error("Invalid attack provided to execute_attack. Remember to assign an attack in the inspector.")
		return
		
	await attack.on_attack()
	attack.on_finish()


func _process(_delta: float) -> void:
	if not attack_ongoing:
		next_attack()

func _ready() -> void:
	if attacks.size() == 0:
		return
