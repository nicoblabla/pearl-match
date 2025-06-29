extends Node
class_name SoldierManager

static var Instance

@onready var soldier_prefab = load("res://prefabs/soldier.tscn")
@onready var ui_manager = UIManager.Instance
@onready var game_manager = GameManager.Instance
@onready var camera = get_viewport().get_camera_3d()
@onready var particles: GPUParticles3D = get_tree().get_root().get_node("Game/Particles/GPUParticles3D")
@onready var die_sound = $FmodDie
@onready var shoot_sound = $FmodShoot

var soldiers = []
var lane = 0
var lane_size = 10
var lane_margin = 1
var real_count = 0

var CELL_SIZE = 2



func _init():
	Instance = self

func _ready() -> void:
	resize(5)
	update_ui()
	particles.visible = false
	particles.emitting = false
	

var grid := {}

func _process(delta):
	if game_manager.state != "PLAYING" and false:
		return
	var limit_left = -lane_size / 2 + (lane_size + lane_margin) * lane
	var limit_right = lane_size / 2 + (lane_size + lane_margin) * lane
	var leader = get_leader()
	
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
		
		var late = leader.position.x - soldier.position.x
		if late > 6 and soldiers.size() > 50:
			separation_force.x -= late * 0.1
			
		separation_force.y = 0
		soldier.linear_velocity += separation_force * delta * 10
	if soldiers.size() > 0:
		particles.emitting = true
		particles.position.x = leader.position.x
		particles.position.z = leader.position.z
	else:
		particles.emitting = false
		
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
func get_leader():
	if soldiers.size() == 0:
		return null
	var max_x: float = 0
	var leader = null
	
	for soldier in soldiers:
		if soldier.position.x > max_x:
			max_x = soldier.position.x
			leader = soldier
			
	return leader
	
func get_leader_position():
	if soldiers.size() == 0:
		return 20
	return get_leader().position.x

func get_count():
	return soldiers.size()
	
func resize(count_diff):
	var count = real_count + count_diff
	var display_count  = get_display_count(count_diff)
	if count <= 0:
		game_over()
	elif count_diff < 0:
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
	real_count = count
	update_ui()
	update_particles()
	
func kill(soldier):
	var displayed_soldiers = soldiers.filter(func(s) -> bool:
		return not s.is_dead
	).size()
	if (displayed_soldiers > 0):
		var ratio = real_count / displayed_soldiers
		real_count -= floor(ratio)
	soldier.die()
	die_sound.play()
	if real_count <= 0:
		game_over()
	update_ui()
	update_particles()
		
func get_damage():
	return real_count
	
func game_over():
	for soldier in soldiers:
		soldier.queue_free()
		soldiers.clear()
		ui_manager.show_game_over()
		
	AnnoyingAdd.Instance.open_random_ad()
		
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
var is_shooting = false
func start_shooting():
	if not is_shooting:
		print("start shooting")
		particles.visible = true
		particles.emitting = true
		shoot_sound.play()
		is_shooting = true
	
func stop_shooting():
	if is_shooting:
		print("stop shooting")
		particles.visible = false
		particles.emitting = false
		shoot_sound.stop()
		is_shooting = false
	
func update_ui():
	ui_manager.update_text(real_count, soldiers.size())
	var power = 1
	if real_count > 50:
		power = 2
	if real_count > 100:
		power = 3
	if real_count > 1000:
		power = 4
	game_manager.change_power(power)

var have_already_changed_bullets = false
func update_particles():
	var material = particles.process_material as ParticleProcessMaterial
	particles.set_amount(max(min(real_count, 800), 100))
	var scale = get_scaled_value(real_count)
	material.scale_max = scale
	material.scale_min = scale
	if real_count > 5000 and not have_already_changed_bullets:
		var new_texture = load("res://textures/bullet_3.tres")
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = new_texture
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		particles.draw_pass_1.material = mat
		have_already_changed_bullets = true

func get_scaled_value(real_count: float) -> float:
	if real_count < 100:
		return remap(real_count, 5, 100, 0.8, 1.5)
	elif real_count < 1000:
		return remap(real_count, 100, 1000, 1.5, 2.0)
	elif real_count < 50000:
		return remap(real_count, 1000, 50000, 2.0, 3.0)
	elif real_count <= 10000000:
		return remap(real_count, 50000, 10000000, 3.0, 4.0)
	else:
		return 4.0  # cap at max
