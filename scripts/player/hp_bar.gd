extends ProgressBar

@export var health: Node;
var max_health: int = 100;

func _ready() -> void:
	health.connect("health_changed", on_health_changed)
	max_health = health.maxHealth
	self.value = 100

func on_health_changed(new_health: int) -> void:
	self.value = float(new_health) / float(max_health) * 100
