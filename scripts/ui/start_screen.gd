extends Control

var start_button: Button
var close_button: Button
var paused: Label
@onready var _bus := AudioServer.get_bus_index("SFX")
@onready var current_volume: float = AudioServer.get_bus_volume_db(_bus)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	start_button = find_child("Button")
	start_button.connect("pressed", _on_start_button_pressed)
	close_button = find_child("CloseButton")
	close_button.connect("pressed", _on_close_button_pressed)
	paused = find_child("paused")
	paused.hide()

func _on_start_button_pressed() -> void:
	var level_controller = get_tree().root.get_node("LevelController")
	level_controller.change_level_scene(level_controller.level_scene)
	get_tree().paused = false

func _on_close_button_pressed() -> void:
	get_tree().quit()
