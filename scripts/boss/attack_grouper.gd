class_name AttackGrouper extends Node

var attacks: Array[BossAttack] = []

func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is BossAttack:
			attacks.append(child)