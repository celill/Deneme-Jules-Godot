extends Node

@export var enemy_scene : PackedScene
@export var spawn_interval = 2.0
@export var spawn_radius = 30.0

var spawn_timer = 0.0
var player : Node3D = null
var score = 0
var health_bar : ProgressBar = null
var score_label : Label = null
var game_over = false

func _ready():
	player = get_tree().get_first_node_in_group("Player")

	health_bar = get_node("UI/Control/HealthBar")
	score_label = get_node("UI/Control/ScoreLabel")

	if player:
		player.connect("health_changed", Callable(self, "_on_player_health_changed"))
		player.connect("player_died", Callable(self, "_on_player_died"))

func _process(delta):
	if game_over:
		if Input.is_action_just_pressed("ui_accept"): # Space / Enter
			get_tree().reload_current_scene()
		return

	if not is_instance_valid(player):
		return

	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_enemy()
		spawn_timer = spawn_interval

func spawn_enemy():
	if not enemy_scene or not is_instance_valid(player):
		return

	var angle = randf() * PI * 2
	var spawn_pos = player.global_position + Vector3(cos(angle), 0, sin(angle)) * spawn_radius

	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = spawn_pos
	enemy.look_at(player.global_position, Vector3.UP)
	# Listen for enemy death if needed for score, but simpler to have enemy signal global event or main game polls?
	# Better: use groups or signal
	enemy.connect("tree_exited", Callable(self, "_on_enemy_killed"))

func _on_player_health_changed(current, max_hp):
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current

func _on_player_died():
	game_over = true
	if score_label:
		score_label.text = "GAME OVER\nFinal Score: " + str(score) + "\nPress SPACE to Restart"

func _on_enemy_killed():
	# tree_exited is called on queue_free(), but also on scene change.
	# For this simple MVP it's okay, but better to have a custom signal "died"
	if is_instance_valid(player): # Only score if player is alive
		score += 10
		if score_label:
			score_label.text = "Score: " + str(score)
