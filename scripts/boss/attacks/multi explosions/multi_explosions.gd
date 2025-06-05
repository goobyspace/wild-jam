extends BossAttack
@export var width_range: float = 5.0
@export var depth_range: float = 5.0
@export var explosion_mesh: PackedScene

@export var amount: int = 5

@export var startup_time: float = 1.0
@export var active_time: float = 2.0
@export var cleanup_time: float = 0.5
@export var damage: int = 10
@export var scale: float = 10.0

@export var top_parent: Node3D

var explosions = []
var hitboxes = []

func _ready() -> void:
	super._ready()
	if explosion_mesh == null:
		push_error("Explosion mesh is not set, please assign it in the editor.")
		return

func explosion_start() -> void:
	for i in range(amount):
		var explosion = explosion_mesh.instantiate()
		explosions.append(explosion)
		self.add_child(explosion)
		var player_position = top_parent.player.position
		explosion.position = Vector3(
			randf_range(-width_range / 2, width_range / 2),
			0,
			randf_range(-depth_range / 2, depth_range / 2)
		) + player_position
		var hitbox = explosion.find_child("DamageCollider")
		hitbox.damage = damage
		hitbox.monitoring = false
		hitbox.connect("body_entered", hitbox._on_body_entered)
		hitboxes.append(hitbox)
		explosion.explode(startup_time, scale, Color(1, 0, 0, 0.9)) # Red color for explosion

func explosion_activate() -> void:
	for hitbox in hitboxes:
		hitbox.activate()

func explosion_cleanup() -> void:
	for hitbox in hitboxes:
		hitbox.monitoring = false
	for explosion in explosions:
		explosion.reset(cleanup_time)

func explosion_clear() -> void:
	for explosion in explosions:
		explosion.queue_free()

func attack() -> bool:
	play_animation()
	explosion_start()
	await get_tree().create_timer(startup_time).timeout
	explosion_activate()
	await get_tree().create_timer(active_time).timeout
	explosion_cleanup()
	await get_tree().create_timer(cleanup_time).timeout
	explosion_clear()
	explosions.clear()
	hitboxes.clear()
	return true
