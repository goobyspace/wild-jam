extends PlayerAttack

func on_attack() -> bool:
	print("Sword main attack executed.")
	animation_player.play("player/attack", 0.1, 1.5)
	return true
