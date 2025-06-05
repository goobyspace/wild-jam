class_name WeirdExplosionMesh extends MeshInstance3D

var radius: float = 0.1
var starting_color: Color
var tween: Tween
var material: StandardMaterial3D
func _ready() -> void:
	scale = Vector3(radius, radius, radius)
	material = self.get_active_material(0)
	starting_color = material.albedo_color

func explode(timer: float, explosion_radius: float, first_color: Color, second_color) -> void:
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3(explosion_radius, 1, explosion_radius), timer).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color", first_color, timer)
	await tween.finished
	material.albedo_color = second_color

func reset(timer: float):
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3(radius, 1, radius), timer).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color", starting_color, timer)
	await tween.finished
