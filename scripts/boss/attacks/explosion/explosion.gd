extends BossAttack

@export var explosion_active_delay: float = 1.0 # Time until the hitbox is active
@export var explosion_active_timer: float = 2.0 # Time the hitbox is active
@export var explosion_cosmetic_linger_timer: float = 0.5 # Time the explosion cosmetic lingers after the hitbox is gone
@export var explosion_damage: int = 10 # Damage dealt by the explosion
@export var explosion_radius: float = 10.0 # Radius of the explosion hitbox
@export var explosion_node: PackedScene

@export var knockback_duration: float = 0.5
@export var knockback_strength: float = 10.0
@export var knockback_lock_movement: bool = true

var explosion_mesh: ExplosionMesh
var explosion_hitbox: DamageCollider

func _ready() -> void:
	super._ready()
	if explosion_node == null:
		push_error("Explosion node is not set, please assign it in the editor.")
		return

func attack() -> bool:
	play_animation()
	explosion_mesh = explosion_node.instantiate()
	if explosion_mesh.has_method("explode") == false or explosion_mesh.has_method("reset") == false:
		push_error("Explosion mesh does not have the required methods.")
		return false
	self.add_child(explosion_mesh)
	explosion_hitbox = explosion_mesh.find_child("DamageCollider")
	explosion_hitbox.knockback_duration = knockback_duration
	explosion_hitbox.knockback_speed = knockback_strength
	explosion_hitbox.lock_movement = knockback_lock_movement
	explosion_hitbox.connect("body_entered", explosion_hitbox._on_body_entered)
	explosion_hitbox.damage = explosion_damage
	explosion_hitbox.monitoring = false
	await explosion_mesh.explode(explosion_active_delay, explosion_radius, Color(1, 0, 0, 0.3), Color(1, 0, 0, 0.5)) # Red color for explosion
	explosion_hitbox.activate()
	await get_tree().create_timer(explosion_active_timer).timeout
	explosion_hitbox.monitoring = false
	await explosion_mesh.reset(explosion_cosmetic_linger_timer)
	return true

func cleanup():
	explosion_mesh.queue_free()
	explosion_mesh = null
	return
