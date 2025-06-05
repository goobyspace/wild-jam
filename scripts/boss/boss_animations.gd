class_name BossAnimations extends AnimationTree

enum Animations {
	raise,
	shoot,
	stamp,
	hover,
}

const AnimTranslation = {
	Animations.raise: "parameters/raise/request",
	Animations.shoot: "parameters/shoot/request",
	Animations.hover: "parameters/hover/blend_amount",
	Animations.stamp: "parameters/stamp/request",
}


func execute_animation(anim: Animations) -> void:
	set(AnimTranslation[anim], AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func stop_animation(anim: Animations) -> void:
	set(AnimTranslation[anim], AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func set_blend_animation(anim: Animations, blend_amount: float) -> void:
	set(AnimTranslation[anim], blend_amount)
