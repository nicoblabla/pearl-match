extends Node
class_name SoldierManager

static var Instance

@onready var soldier_prefab = load("res://prefabs/soldier.tscn")
@onready var ui_manager = UIManager.Instance
var soldiers = []
var lane = 0
var lane_size = 10
var lane_margin = 1
var real_count = 0



func _init():
	Instance = self

func _ready() -> void:
	for i in range(5):
		add_soldier()
	update_ui()

	
func _process(delta):
	if false:
		return
	var leader_position = get_leader_position()
	# Move all soldiers forward
	for soldier in soldiers:
		soldier.linear_velocity.x = lerp(soldier.linear_velocity.x, soldier.speed, 10 * delta)
		soldier.linear_velocity.z = lerp(soldier.linear_velocity.z, 0.0, 10 * delta)
		#soldier.linear_velocity.y = max(soldier.linear_velocity.y, 0.1)
	
	# Apply separation force to prevent crowding
	for i in range(soldiers.size()):
		var soldier = soldiers[i]
		var separation_force = Vector3.ZERO
			
		# Changing lanes
		if soldier.is_changing_lane:
			if soldier.is_changing_lane_in <= 0:
				var dist = soldier.target_position - soldier.position.z
				separation_force.z += clamp(dist, -3, 3) * 5
				if abs(dist) < 1:
					soldier.is_changing_lane = false
					separation_force.z = 0
		else:
			# Stay on their lane
			var limit_left = -lane_size / 2 + (lane_size + lane_margin) * lane
			var limit_right = lane_size / 2 + (lane_size + lane_margin) * lane
			if soldier.position.z < limit_left:
				separation_force.z = (limit_left - soldier.position.z) * 5
			elif soldier.position.z >  limit_right:
				separation_force.z = (limit_right - soldier.position.z) * 5
			var middle_lane = (limit_left + limit_right) / 2
			# small force near the middle of the lane
			if abs(soldier.position.z - middle_lane) > 0.5:
				separation_force.z += sign(middle_lane - soldier.position.z) * 0.5
				

		
		# Check distance to other soldiers and apply separation force
		for j in range(soldiers.size()):
			if i != j:
				var other_soldier = soldiers[j]
				var distance = soldier.position.distance_to(other_soldier.position)
				if distance < 1.2:  # Adjust this threshold as needed
					var direction = (soldier.position - other_soldier.position).normalized()
					direction.z = 0
					separation_force += direction * (1.2 - distance)
					if distance < 0.5:  # If too close, push away more strongly
						separation_force += direction * (0.5 - distance) * 5
		# Speed up late soldier
		var late = leader_position - soldier.position.x
		if leader_position - soldier.position.x > 20:
			separation_force.x += max(late * 0.5, 5)
			
		separation_force.y = 0
		soldier.linear_velocity += separation_force * delta * 10
	
	# Remove any soldiers that are too far behind
	# TODO


func add_soldier():
	print("adding soldier")
	var soldier = soldier_prefab.instantiate()
	soldier.position = Vector3(
		get_leader_position() - 1,
		5,
		0 + randf_range(-lane_size/2, lane_size/2) + lane * (lane_size + lane_margin))
	soldier.add_to_group("soldier")
	add_child(soldier)
	soldiers.append(soldier)
	real_count+=1
	print("Soldier added, total count: " + str(real_count))
	return soldier

# Get the soldier at the front of the group (x-axis)
func get_leader_position() -> float:
	if soldiers.size() == 0:
		return 20
	var max_x: float = 0
	
	for soldier in soldiers:
		if soldier.position.x > max_x:
			max_x = soldier.position.x
			
	return max_x
	
func get_leader() -> Node3D:
	if soldiers.size() == 0:
		return null
	var max_x: float = 0
	var leader = null
	
	for soldier in soldiers:
		if soldier.position.x > max_x:
			max_x = soldier.position.x
			leader = soldier
			
	return leader

func get_count():
	return soldiers.size()
	
func resize(count):
	print("current: " + str(soldiers.size()) + " new: " + str(count) + "real: " + str(real_count))
	var display_count  = get_display_count(count)
	if display_count <= 0:
		for soldier in soldiers:
			soldier.queue_free()
		soldiers.clear()
		print("game over")
	elif display_count < soldiers.size():
		# Remove soldiers if count is less than current size
		for i in range(soldiers.size() - 1, display_count - 1, -1):
			var soldier = soldiers[i]
			soldier.queue_free()
			soldiers.erase(soldier)
	else:
		# Add soldiers if count is greater than current size
		for i in range(display_count - soldiers.size()):
			add_soldier()
	print("displaycount: " + str(display_count) + " realcount: " + str(real_count))
	real_count = count
	update_ui()

var touch_start = Vector2.ZERO
var min_swipe_distance = 100  # in pixels

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position  # finger down
	elif event is InputEventScreenDrag:
		var swipe_vector = event.position - touch_start
		if swipe_vector.length() > min_swipe_distance:
			if abs(swipe_vector.x) > abs(swipe_vector.y):  # horizontal swipe
				if swipe_vector.x > 0:
					on_swipe_right()
				else:
					on_swipe_left()
			# reset to avoid double triggering
			touch_start = event.position
	elif event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_LEFT || event.keycode == KEY_A:
				on_swipe_left()
			elif event.keycode == KEY_RIGHT || event.keycode == KEY_D:
				on_swipe_right()
func get_display_count(real_count):
	if real_count < 30:
		return real_count
	return 33.2 * log((real_count * 10) / 20) + 7.7
func on_swipe_left():
	on_swipe(-1)
			
func on_swipe_right():
	on_swipe(1)
			
func on_swipe(direction: float):
	if abs(lane + direction) <= 1:
		lane += direction
		var leader_position = get_leader_position()
		for soldier in soldiers:
			var current_position = soldier.target_position if soldier.is_changing_lane else soldier.position.z
			soldier.target_position = current_position + (lane_size + lane_margin) * direction
			soldier.is_changing_lane = true
			soldier.is_changing_lane_in = (leader_position - soldier.position.x) / 60

func update_ui():
	ui_manager.update_text(real_count, soldiers.size())
