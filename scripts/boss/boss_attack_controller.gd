extends Node

@export var attacks: Array[BossAttack] = []
var current_attack_index: int = 0
var tree: SceneTree

func execute_attack(attack: BossAttack):
    if attack == null:
        return
    var attack_result = await attack.on_attack()
    print("Attack was succesfully executed: ", attack_result)
    attack.on_finish()

func _ready() -> void:
    tree = get_tree()
    if attacks.size() == 0:
        return

    while current_attack_index < attacks.size():
        await execute_attack(attacks[current_attack_index])
        current_attack_index += 1
        if current_attack_index >= attacks.size():
            current_attack_index = 0 # Reset to the first attack if all have been executed
