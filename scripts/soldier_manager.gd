extends Node
class_name SoldierManager

static var Instance

@onready var soldier_prefab = load("res://prefabs/soldier.tscn")
@onready var ui_manager = UIManager.Instance
@onready var camera = get_viewport().get_camera_3d()

var soldiers = []
var lane = 0
var lane_size = 10
var lane_margin = 1
var real_count = 0

var CELL_SIZE = 2



func _init():
	Instance = self

func _ready() -> void:
	for i in range(5):
		add_soldier()
	update_ui()
	

var grid := {}

func _process(delta):
	if false:
		return
	var limit_left = -lane_size / 2 + (lane_size + lane_margin) * lane
	var limit_right = lane_size / 2 + (lane_size + lane_margin) * lane
	var leader_position = get_leader_position()
	


	# Move all soldiers forward
	for soldier in soldiers:
		if soldier.is_dead:
			pass
		soldier.linear_velocity.x = lerp(soldier.linear_velocity.x, soldier.speed, 10 * delta)
		soldier.linear_velocity.z = lerp(soldier.linear_velocity.z, 0.0, 10 * delta)
		#soldier.linear_velocity.y = max(soldier.linear_velocity.y, 0.1)
	
	# Apply separation force to prevent crowding
	var size = soldiers.size()
	for i in range(size):
		if i >= soldiers.size():
			break
		var soldier = soldiers[i]
			
		if camera.unproject_position(soldier.position).y - 150 > get_viewport().get_visible_rect().size.y:
			soldier.queue_free()
			soldiers.erase(soldier)
			i -= 1
			size -= 1
			continue
		
		if soldier.is_dead:
			continue
		
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
			if soldier.position.z < limit_left:
				separation_force.z = (limit_left - soldier.position.z) * 5
			elif soldier.position.z >  limit_right:
				separation_force.z = (limit_right - soldier.position.z) * 5
			var middle_lane = (limit_left + limit_right) / 2
			# small force near the middle of the lane
			if abs(soldier.position.z - middle_lane) > 0.5:
				separation_force.z += sign(middle_lane - soldier.position.z) * 0.5
		
		var late = leader_position - soldier.position.x
		if late > 6 and soldiers.size() > 50:
			separation_force.x -= late * 0.1
			
		separation_force.y = 0
		soldier.linear_velocity += separation_force * delta * 10
		
#	for soldier in soldiers:
#		if soldier.is_dead:
#			soldier.queue_free()
#			soldiers.erase(soldier)



func get_cell_coords(pos: Vector3) -> Vector2i:
	return Vector2i(floor(pos.x / CELL_SIZE), floor(pos.z / CELL_SIZE))
	
func add_soldier():
	var soldier = soldier_prefab.instantiate()
	soldier.position = Vector3(
		get_leader_position() - 1,
		5,
		0 + randf_range(-lane_size/2., lane_size/2.) + lane * (lane_size + lane_margin))
	soldier.add_to_group("soldier")
	add_child(soldier)
	soldiers.append(soldier)
	real_count+=1
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
	
func resize(count_diff):
	var count = real_count + count_diff
	var display_count  = get_display_count(count_diff)
	if count <= 0:
		for soldier in soldiers:
			soldier.queue_free()
		soldiers.clear()
		print("game over")
	elif count_diff < 0:
		print("display_count", display_count)
		print(soldiers.size())
		print("real_count", real_count)
		print(count_diff)
		for i in range(soldiers.size() - 1, (soldiers.size() + count_diff) - 1, -1):
			if soldiers.size() > 40 || real_count < 50:
				var soldier = soldiers[i]
				#soldier.queue_free()
				#soldiers.erase(soldier)
				soldier.die()
	else:
		# Add soldiers if count is greater than current size
		for i in range(count_diff):
			if soldiers.size() < 100:
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
