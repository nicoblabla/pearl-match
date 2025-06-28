extends RigidBody3D

var speed: float = 10.0

var speed_variation = 0.1
var default_speed = 30.0
var time_until_next_speed_change = randf_range(0.3, 2)

var target_position: float = 1000
var is_changing_lane: bool = false
var is_changing_lane_in: float = 0

@onready var animation = $"Firing Rifle/AnimationPlayer"

func _ready() -> void:
	change_speed()
	animation.get_animation("mixamo_com").loop = true
	animation.play("mixamo_com", )
	

func _process(delta: float) -> void:
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
