extends ProgressBar

@export var health_decrease_duration: float = 0.25;
var max_health: int = 100;

func _ready() -> void:
	var health = get_node("../../Enemy/enemy_health")
	health.connect("health_changed", on_health_changed)
	health.connect("health_depleted", self.hide)
	max_health = health.maxHealth
	self.value = max_health

func on_health_changed(new_health: int) -> void:
	self.show()
	var newValue = float(new_health) / float(max_health) * 100
	var tween = create_tween()
	tween.tween_property(self, "value", newValue, health_decrease_duration).set_trans(Tween.TRANS_BOUNCE)
