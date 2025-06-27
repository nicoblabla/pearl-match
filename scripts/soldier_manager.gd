extends Node

var soldiers = []

func _ready() -> void:
	add_soldier()
	add_soldier()
	add_soldier()
	add_soldier()
	add_soldier()
	add_soldier()
	add_soldier()
	add_soldier()

	
func _process(delta):

	# Move all soldiers forward
	for soldier in soldiers:
		soldier.linear_velocity.x = lerp(soldier.linear_velocity.x, 1.0, 1 * delta)
		soldier.linear_velocity.z = lerp(soldier.linear_velocity.z, 0.0, 1 * delta)
	
	# Apply separation force to prevent crowding
	for i in range(soldiers.size()):
		var soldier = soldiers[i]
		var separation_force = Vector3.ZERO
		
		# Apply force to keep soldier in z between -0.5 and 0.5
		if soldier.position.z < -0.5:
			separation_force.z = 0.5 - soldier.position.z
		elif soldier.position.z > 0.5:
			separation_force.z = 0.5 - soldier.position.z
		
		# Check distance to other soldiers and apply separation force
		for j in range(soldiers.size()):
			if i != j:
				var other_soldier = soldiers[j]
				var distance = soldier.position.distance_to(other_soldier.position)
				
				if distance < 0.1:  # Adjust this threshold as needed
					var direction = (soldier.position - other_soldier.position).normalized()
					direction.z = 0 
					separation_force += direction * (0.1 - distance)  # Apply a force proportional to the distance
				
		soldier.linear_velocity += separation_force * delta * 50
	
	# Remove any soldiers that have fallen off the map
	for soldier in soldiers:
		if soldier.position.x < -10:
			soldier.queue_free()
			soldiers.erase(soldier)
	
	# Add a new soldier if the group is too small
	if soldiers.size() < 3:
		add_soldier()

func add_soldier():
	var soldier = load("res://prefabs/soldier.tscn").instantiate()
	soldier.position = Vector3(1.09, 1.153, 0 + randf()*0.5)
	add_child(soldier)
	soldiers.append(soldier)

# Get the soldier at the front of the group (x-axis)
func get_group_position() -> float:
	if soldiers.size() == 0:
		return 0
	var max_x: float = 0
	
	for soldier in soldiers:
		if soldier.position.x > max_x:
			max_x = soldier.position.x
			
	return max_x
