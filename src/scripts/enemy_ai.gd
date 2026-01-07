extends RigidBody3D

@export var speed = 100.0
@export var damage = 10.0
@export var health = 30.0
@export var explosion_scene : PackedScene

var player : RigidBody3D = null

func _ready():
	# Find player in the scene
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	if is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		direction.y = 0 # Keep movement on plane
		apply_central_force(direction * speed)

		# Look at player
		if linear_velocity.length() > 1.0:
			look_at(global_position + linear_velocity, Vector3.UP)

func take_damage(amount):
	health -= amount
	if health <= 0:
		spawn_explosion()
		queue_free()
		# Add xp drop logic here later

func spawn_explosion():
	if explosion_scene:
		var expl = explosion_scene.instantiate()
		get_tree().root.add_child(expl)
		expl.global_position = global_position
		expl.emitting = true

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

		# Simple knockback
		var dir = (body.global_position - global_position).normalized()
		body.apply_impulse(dir * 20.0)

		# Remove the heavy bounce back to let them ram into the player
		# Just a small push back to avoid clipping
		var bounce_dir = (global_position - body.global_position).normalized()
		apply_impulse(bounce_dir * 5.0)
