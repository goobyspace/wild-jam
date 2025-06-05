extends Control

var victory_fox: SubViewportContainer
var victory_dog: SubViewportContainer
var start_button: Button
var close_button: Button
var label: Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button = find_child("Button")
	start_button.connect("pressed", _on_start_button_pressed)
	close_button = find_child("CloseButton")
	close_button.connect("pressed", _on_close_button_pressed)
	label = find_child("toptext")
	victory_fox = find_child("victoryfox")
	victory_dog = find_child("victorydog")
	get_tree().root.get_node("Main/Player/player_health").connect("health_depleted", on_defeat)
	get_tree().root.get_node("Main/Enemy/enemy_health").connect("health_depleted", on_victory)
	victory_dog.hide()
	victory_fox.hide()
	hide()

func _on_start_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_close_button_pressed() -> void:
	get_tree().quit()

func end():
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
