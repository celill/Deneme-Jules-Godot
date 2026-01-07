extends Node3D

@export var projectile_scene : PackedScene
@export var fire_rate = 0.5
@export var range_radius = 20.0

var fire_timer = 0.0

func _process(delta):
	fire_timer -= delta
	if fire_timer <= 0:
		var target = find_nearest_enemy()
		if target:
			fire_at(target)
			fire_timer = fire_rate

func find_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var nearest : Node3D = null
	var min_dist = range_radius

	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy

	return nearest

func fire_at(target):
	if not projectile_scene:
		return

	var proj = projectile_scene.instantiate()
	get_tree().root.add_child(proj)
	proj.global_position = global_position + Vector3(0, 1, 0) # Fire from slightly above

	var dir = (target.global_position - global_position).normalized()
	proj.velocity = dir * proj.speed
