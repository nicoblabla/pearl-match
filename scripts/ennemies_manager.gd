class_name EnemyManager
extends Node3D

@export var enemy_spawn_data: Array[EnemySpawnData] = []
@export var spawn_interval: float = 2.0
@export var spawn_width: float = 20.0
@export var spawn_height_offset: float = 300

@export_range(1, 10, 1) var spawn_batch_size: int = 1  # Nombre d'ennemis à générer par batch

@onready var soldier_manager = SoldierManager.Instance

var spawn_timer: float = 0.0
var viewport_size: Vector2

func _ready() -> void:
	viewport_size = get_viewport().get_visible_rect().size

func _process(delta: float) -> void:
	if soldier_manager.soldiers.size() <= 0:
		return
	spawn_timer += delta

	if spawn_timer >= spawn_interval:
		spawn_enemy()
		spawn_timer = 0.0
	
	var is_someone_in_range = false
	for enemy in get_children():
		if not enemy.is_dead:
			if enemy.in_range:
				is_someone_in_range = true
	if not is_someone_in_range:
		soldier_manager.stop_shooting()
	else:
		soldier_manager.start_shooting()

func select_random_enemy() -> EnemySpawnData:
	if enemy_spawn_data.is_empty():
		return null

	# Calcul de la somme totale des probabilités
	var total_probability: float = 0.0
	for data in enemy_spawn_data:
		total_probability += data.spawn_chance

	# Tirage aléatoire
	var random_value = randf() * total_probability
	var current_sum = 0.0

	for data in enemy_spawn_data:
		current_sum += data.spawn_chance
		if random_value <= current_sum:
			return data

	# Fallback au cas où
	return enemy_spawn_data[0]

func spawn_enemy() -> void:

	var enemies_to_spawn = randi_range(1, spawn_batch_size)

	# Position aléatoire derrière le haut de l'écran
	var spawn_lane = [-1, 0, 1].pick_random()
	var spawn_x = soldier_manager.get_leader_position() + spawn_height_offset
	for i in range(enemies_to_spawn):
		var random_data = select_random_enemy()
		var random_scene = random_data.enemy_scene
		var enemy_instance : Ennemy = random_scene.instantiate()
		enemy_instance.lane = spawn_lane
		enemy_instance.max_life = random_data.max_health
		enemy_instance.life = random_data.max_health
		enemy_instance.scale.x = random_data.scale
		enemy_instance.scale.y = random_data.scale
		enemy_instance.scale.z = random_data.scale

		# Générer une position aléatoire autour d'un cercle
		var angle = randf() * 2.0 * PI
		var radius = randf_range(3.0, 6.0)
		var offset_x = radius * cos(angle)
		var offset_z = radius * sin(angle)
		enemy_instance.position = Vector3(spawn_x + offset_x, 0, spawn_lane * 12 + offset_z)
	
		# Ajouter l'ennemi à la scène
		self.add_child(enemy_instance)

		var anim_player = enemy_instance.get_node_or_null("AnimationPlayer")
		if anim_player:
			anim_player.play("running")
