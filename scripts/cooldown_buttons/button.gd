extends Control

@export var icon: TextureRect
@export var cooldown_progress: TextureProgressBar
@export var keybind_button: Control
@export var mouse_button: TextureRect
@export var space_bar: TextureRect
var keybind_border: TextureRect
var keybind_label: Label

var ability: PlayerAbility

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not icon or not cooldown_progress or not keybind_button or not mouse_button or not space_bar:
		push_error("One or more UI elements are not assigned in the Icon UI scene.")
		return
	
func set_ability(new_ability: PlayerAbility) -> void:
	ability = new_ability
	if ability:
		icon.texture = ability.icon
		cooldown_progress.value = 0

		space_bar.visible = false
		mouse_button.visible = false
		keybind_button.visible = false

		var keybind = InputMap.action_get_events(ability.keybind.action)[0]

		if keybind is InputEventKey:
			keybind_border = keybind_button.get_node("keybind_border")
			keybind_label = keybind_button.get_node("keybind_label")
			keybind_label.text = OS.get_keycode_string(keybind.physical_keycode)
			if keybind.physical_keycode == KEY_SPACE:
				space_bar.visible = true
			else:
				keybind_button.visible = true
		elif keybind is InputEventMouseButton:
			mouse_button.visible = true

func _any_ability_used(ability_used, gcd) -> void:
	if ability_used != ability:
		cooldown_progress.value = 100
		var tween = create_tween()
		tween.tween_property(cooldown_progress, "value", 0, gcd)


func _on_ability_used(_ability) -> void:
	if ability:
		cooldown_progress.value = 100
		var tween = create_tween()
		tween.tween_property(cooldown_progress, "value", 0, ability.ability_cooldown)
