extends Node3D

@onready var wall_prefabs = load("res://prefabs/wall.tscn")

func _ready() -> void:
	var pos_x = 200
	
	while pos_x < 1000:
		pos_x += 50 + randf() * 5  # Randomize the position a bit
		spawn_wall(pos_x)
	

func spawn_wall(pos_x: float) -> void:
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
			return Vector2i(0, randi_range(2, 4))
		"combined":
			var value = randi_range(-40, 3) # TODO Random between - soldier size and 3
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
