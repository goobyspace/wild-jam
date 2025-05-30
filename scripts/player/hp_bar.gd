extends ProgressBar

@export var health: Node;
@export var health_decrease_duration: float = 0.25;
var max_health: int = 100;

func _ready() -> void:
	self.hide()
	health.connect("health_changed", on_health_changed)
	max_health = health.maxHealth
	self.value = 100

func on_health_changed(new_health: int) -> void:
	self.show()
	var newValue = float(new_health) / float(max_health) * 100
	var tween = create_tween()
	tween.tween_property(self, "value", newValue, health_decrease_duration)
