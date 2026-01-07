extends Node3D

@export var speed = 40.0
@export var damage = 10.0
@export var life_time = 2.0

var velocity = Vector3.ZERO

func _process(delta):
	global_position += velocity * delta

	life_time -= delta
	if life_time <= 0:
		queue_free()

func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
