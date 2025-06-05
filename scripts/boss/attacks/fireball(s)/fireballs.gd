extends BossAttack

@export var delay: float = 0.5
@export var travel_time: float = 1.0
@export var damage: int = 5
@export var amount: int = 3
@export var knockback_duration: float = 0.3
@export var knockback_strength: float = 5.0
@export var fireball_node: PackedScene
@export var top_parent: Node3D

var player: Node3D

func _ready() -> void:
	super._ready()
	if fireball_node == null:
		push_error("Fireball node is not set, please assign it in the editor.")
		return
	if not top_parent:
		push_error("Fireball parent is not set, please assign it in the editor.")
		return
	
	player = top_parent.get_parent().find_child("Player")

func spawn_fireball():
	var fireball = fireball_node.instantiate()
	top_parent.add_sibling(fireball)
	var hitbox = fireball.find_child("DamageCollider")
	hitbox.activate()
	hitbox.damage = damage
	hitbox.knockback_duration = knockback_duration
	hitbox.knockback_speed = knockback_strength
	hitbox.connect("body_entered", hitbox._on_body_entered)
	fireball.look_at(player.position, Vector3.UP)
	fireball.rotation.y -= PI
	var tween = get_tree().create_tween()
	tween.tween_property(fireball, "position", fireball.global_basis.z * 100, travel_time)
	await tween.finished
	fireball.queue_free()

func attack() -> bool:
	for i in range(amount):
		play_animation()
		await get_tree().create_timer(delay).timeout
		top_parent.look_at_player()
		spawn_fireball()
	return true
