extends RigidBody3D

signal health_changed(current, max)
signal player_died

@export var acceleration = 150.0
@export var steering_speed = 5.0
@export var drift_factor = 0.95 # Lower = more drift, Higher = more grip
@export var max_health = 100.0

var current_health = 100.0
var move_input = 0.0
var steer_input = 0.0

func _ready():
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

func take_damage(amount):
	current_health -= amount
	emit_signal("health_changed", current_health, max_health)
	if current_health <= 0:
		emit_signal("player_died")
		queue_free()

func _physics_process(delta):
	# Get input
	move_input = Input.get_axis("ui_down", "ui_up")
	steer_input = Input.get_axis("ui_right", "ui_left")

	# Apply central force for movement (local forward vector)
	var forward_dir = -transform.basis.z
	if move_input != 0:
		apply_central_force(forward_dir * move_input * acceleration)

	# Apply torque for steering
	if steer_input != 0:
		apply_torque(Vector3.UP * steer_input * steering_speed)

	# Drift mechanics: Dampen velocity perpendicular to forward direction
	var local_velocity = transform.basis.inverse() * linear_velocity
	local_velocity.x *= drift_factor # Slide
	linear_velocity = transform.basis * local_velocity
