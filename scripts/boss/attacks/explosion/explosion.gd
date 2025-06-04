extends BossAttack

@export var explosion_active_delay: float = 1.0 # Time until the hitbox is active
@export var explosion_active_timer: float = 2.0 # Time the hitbox is active
@export var explosion_cosmetic_linger_timer: float = 0.5 # Time the explosion cosmetic lingers after the hitbox is gone
@export var explosion_damage: int = 10 # Damage dealt by the explosion
@export var explosion_radius: float = 10.0 # Radius of the explosion hitbox
@export var explosion_node: PackedScene
@export var explosion_audio: AudioStream

var explosion_mesh: ExplosionMesh
var explosion_hitbox: DamageCollider
var explosion_audio_player: AudioStreamPlayer


func _ready() -> void:
	super._ready()
	if explosion_node == null:
		print("Explosion node is not set, please assign it in the editor.")
		return

	#Create Audio Player
	if explosion_audio != null:
		explosion_audio_player = AudioStreamPlayer.new()
		explosion_audio_player.stream = explosion_audio
		explosion_audio_player.volume_db = 0.0
		explosion_audio_player.bus = "SFX"
		add_child(explosion_audio_player)



func attack() -> bool:
	explosion_mesh = explosion_node.instantiate()
	self.add_child(explosion_mesh)
	explosion_hitbox = explosion_mesh.find_child("DamageCollider")
	explosion_hitbox.connect("body_entered", explosion_hitbox._on_body_entered)
	explosion_hitbox.damage = explosion_damage
	explosion_hitbox.monitoring = false

	if explosion_audio_player != null and !explosion_audio_player.is_playing():
		explosion_audio_player.play()

	await explosion_mesh.explode(explosion_active_delay, explosion_radius, Color(1, 0, 0)) # Red color for explosion
	explosion_hitbox.monitoring = true
	await get_tree().create_timer(explosion_active_delay).timeout
	explosion_hitbox.monitoring = false
	await explosion_mesh.reset(explosion_cosmetic_linger_timer)
	return true

func cleanup():
	explosion_mesh.queue_free()
	explosion_mesh = null

	if explosion_audio_player and explosion_audio_player.is_playing():
		explosion_audio_player.stop()

	return
