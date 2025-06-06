class_name PlayerAnimations extends AnimationTree
var current_passive_animation: String = ""
var current_animation_speed: float = 1.0

const WalkState = "parameters/walk_direction/transition_request"
enum WalkAnimations {
	forward,
	left,
	right,
	back,
	idle,
}

const WalkAnimTranslation = {
	WalkAnimations.forward: "forward",
	WalkAnimations.left: "left",
	WalkAnimations.right: "right",
	WalkAnimations.back: "back",
	WalkAnimations.idle: "idle"
}

enum ActionAnimations {
	attack_normal,
	dash,
	spin,
	lunge,
	spell,
	thunder,
}

const ActionAnimTranslation = {
	ActionAnimations.attack_normal: "parameters/attack_normal/request",
	ActionAnimations.dash: "parameters/dash/request",
	ActionAnimations.spin: "parameters/spin/blend_amount",
	ActionAnimations.lunge: "parameters/lunge/request",
	ActionAnimations.spell: "parameters/spell/request",
	ActionAnimations.thunder: "parameters/thunder/request",
}


func set_passive(anim: WalkAnimations) -> void:
	set(WalkState, WalkAnimTranslation[anim])

func execute_action_animation(anim: ActionAnimations) -> void:
	set(ActionAnimTranslation[anim], AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func stop_action_animation(anim: ActionAnimations) -> void:
	set(ActionAnimTranslation[anim], AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func set_blend_action_animation(anim: ActionAnimations, blend_amount: float) -> void:
	set(ActionAnimTranslation[anim], blend_amount)
