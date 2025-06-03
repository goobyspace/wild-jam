class_name knockback
var knockback_vector: Vector3 = Vector3.ZERO
var knockback_speed: float = 0.0
var knockback_duration: float = 0.0
var lock_direction: bool = false

func _init(input_knockback_direction: Vector3, input_knockback_speed: float, input_duration: float, input_lock_direction: bool) -> void:
    knockback_vector = input_knockback_direction
    knockback_speed = input_knockback_speed
    knockback_duration = input_duration
    lock_direction = input_lock_direction