extends Control

var start_button: Button
var close_button: Button
var paused: Label
@onready var _bus := AudioServer.get_bus_index("SFX")
@onready var current_volume: float = AudioServer.get_bus_volume_db(_bus)
var boss_hp: Control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	start_button = find_child("Button")
	start_button.connect("pressed", _on_start_button_pressed)
	close_button = find_child("CloseButton")
	close_button.connect("pressed", _on_close_button_pressed)
	paused = find_child("paused")
	paused.hide()
	boss_hp = get_parent().find_child("ProgressBar")
	boss_hp.hide()

func _on_start_button_pressed() -> void:
	hide()
	boss_hp.show()
	get_tree().paused = false

func _on_close_button_pressed() -> void:
	get_tree().quit()

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			hide()
			get_tree().paused = false
		else:
			show()
			get_tree().paused = true
			paused.show()
			start_button.get_node("NinePatchRect/Label").text = "Continue"
