extends Control

var victory_fox: SubViewportContainer
var victory_dog: SubViewportContainer
var start_button: Button
var close_button: Button
var label: Label
@onready var _bus := AudioServer.get_bus_index("SFX")
var current_volume: float = AudioServer.get_bus_volume_db(_bus)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button = find_child("Button")
	start_button.connect("pressed", _on_start_button_pressed)
	close_button = find_child("CloseButton")
	close_button.connect("pressed", _on_close_button_pressed)
	label = find_child("toptext")
	victory_fox = find_child("victoryfox")
	victory_dog = find_child("victorydog")
	victory_dog.hide()
	victory_fox.hide()
	hide()

func _on_start_button_pressed() -> void:
	AudioServer.set_bus_volume_db(_bus, current_volume)
	var level_controller = get_tree().root.get_node("LevelController")
	level_controller.change_level_scene(level_controller.level_scene)
	get_tree().paused = false


func _on_close_button_pressed() -> void:
	get_tree().quit()

func end():
	current_volume = AudioServer.get_bus_volume_db(_bus)
	AudioServer.set_bus_volume_db(_bus, linear_to_db(0))
	get_tree().paused = true
	show()

func on_victory():
	label.text = "Victory!!!"
	start_button.get_node("NinePatchRect/Label").text = "Try again?"
	victory_fox.show()
	victory_dog.hide()
	end()

func on_defeat():
	label.text = "Defeat..."
	start_button.get_node("NinePatchRect/Label").text = "Try again!"
	victory_fox.hide()
	victory_dog.show()
	end()
