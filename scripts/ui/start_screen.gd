extends Control

var start_button: Button
var close_button: Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	start_button = find_child("Button")
	start_button.connect("pressed", _on_start_button_pressed)
	close_button = find_child("CloseButton")
	close_button.connect("pressed", _on_close_button_pressed)

func _on_start_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_close_button_pressed() -> void:
	get_tree().quit()

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		show()
		get_tree().paused = true