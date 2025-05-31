extends AnimationPlayer
var current_passive_animation: String = ""
var current_animation_speed: float = 1.0


func change_passive_animation(anim_name: String, speed: float = 1.0) -> void:
	if current_passive_animation == anim_name and current_animation_speed == speed:
		return
	if is_playing() and current_animation == current_passive_animation:
		play(anim_name, 0.1, speed)
	current_passive_animation = anim_name
	current_animation_speed = speed

func _process(_delta: float) -> void:
	if not is_playing() and current_passive_animation != "":
		play(current_passive_animation, 0.1, current_animation_speed)
