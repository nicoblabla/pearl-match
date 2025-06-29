extends Node3D

@onready var wall_prefabs = load("res://prefabs/wall.tscn")
@onready var soldier_manager = SoldierManager.Instance

var all_walls = []
var pos_x = 100

func _ready() -> void:
	while pos_x < 300:
		pos_x += 100 + randf() * 50
		spawn_wall(pos_x)
	
func _process(delta: float) -> void:
	if soldier_manager.get_leader_position() > pos_x - 100:
		pos_x += 100 + randf() * 50
		spawn_wall(pos_x)
	
	
func spawn_wall(pos_x: float) -> void:
	print("creating new walls")
	var wall_effects = generate_triplet()
	var walls = []
	for i in range(len(wall_effects)):
		var effect = wall_effects[i]
		if effect.x != 0 or effect.y != 0:
			var wall = wall_prefabs.instantiate()
			wall.position = Vector3(pos_x, 0, (i - 1) * 11)
			add_child(wall)
			walls.append(wall)
			wall.set_value(effect.y, effect.x)
	for wall in walls:
		wall.set_neighbors(walls)
	if walls.size() > 0:
		all_walls.append(walls)

func generate_wall_effect() -> Vector2i:
	var effect_type = weighted_random_choice({
		"nothing": 10,
		"add_only": 3,
		"mul_only": 1,
		"combined": 3,
	})

	match effect_type:
		"nothing":
			return Vector2i(0, 0)
		"add_only":
			var value =  randi_range(-30, 30)
			return Vector2i(value, 0)
		"mul_only":
			return Vector2i(0, randi_range(2, 3))
		"combined":
			var range_min = soldier_manager.real_count
			# round range min if bigger than 1000 to (3084 -> 3000)
			if range_min > 100000:
				range_min = int(range_min / 10000) * 10000
			elif range_min > 10000:
				range_min = int(range_min / 1000) * 1000
			elif range_min > 1000:
				range_min = int(range_min / 100) * 100
			else:
				range_min = int(range_min / 10) * 10
			var value = randi_range(-range_min, 3)
			var mult = randi_range(2, 5)
			return Vector2i(value, mult)
	print("Error: Unknown effect type: ", effect_type)
	return Vector2i(0, 0)

func generate_triplet() -> Array:
	return [
	generate_wall_effect(),
	generate_wall_effect(),
	generate_wall_effect()
	]

func weighted_random_choice(weights: Dictionary) -> String:
	var total = 0
	for value in weights.values():
		total += value
	var rnd = randi_range(1, total)
	for key in weights.keys():
		rnd -= weights[key]
		if rnd <= 0:
			return key
	return weights.keys()[0]  # Fallback
