extends CharacterBody3D
var player: CharacterBody3D
@export var turn_speed: float = 0.5

var turning := 0.0

func _ready() -> void:
	player = get_tree().root.get_node("LevelController/Main/Player")

func look_at_player():
	turning = turn_speed

func _physics_process(delta: float) -> void:
	if turning > 0.0:
		turning -= delta
		var direction = (self.global_position - player.global_position).normalized()
		var angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, angle, 0.1)
