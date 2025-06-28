extends RigidBody3D

var speed: float = 10.0

var speed_variation = 0.1
var default_speed = 30.0
var time_until_next_speed_change = randf_range(0.3, 2)

var target_position: float = 1000
var is_changing_lane: bool = false
var is_changing_lane_in: float = 0

var is_dead = false

@onready var animation = $"main_militar_decimated/AnimationPlayer"

func _ready() -> void:
	change_speed()
	animation.get_animation("walking").loop = true
	animation.play("walking")
	

func _process(delta: float) -> void:
	if is_dead:
		linear_velocity.x = 0
		return
	time_until_next_speed_change -= delta
	if time_until_next_speed_change <= 0:
		time_until_next_speed_change = randf_range(0.3, 2)
		change_speed()
	if is_changing_lane_in > 0:
		is_changing_lane_in -= delta
	
func _integrate_forces(state):
	if position.y <= 0:
		global_position.y = 0
		linear_velocity.y = 0
	else:
		linear_velocity.y = -5

func change_speed():
	speed = randf_range(default_speed - speed_variation, default_speed + speed_variation)

func die():
	is_dead = true
