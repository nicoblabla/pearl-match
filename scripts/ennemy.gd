extends Node3D

@onready var game_manager = GameManager.Instance
@onready var soldier_manager = SoldierManager.Instance
@onready var camera_container = GameManager.Instance.get_node("CameraContainer")

@onready var red = $HealthRed
@onready var green = $HealthGreen

var lane = 0
var enabled = true
var is_dead = false
var life = 100.
var max_life = 100.

func _ready() -> void:
	update_health_bar()
	
func _process(delta: float) -> void:
	if (not is_dead and position.x - camera_container.position.x < 50 and soldier_manager.lane == lane):
		print("take damage")
		take_damage(soldier_manager.get_damage())


func take_damage(damage):
	life -= damage
	if life < 0:
		die()
		visible = false
	update_health_bar()
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if enabled and body.is_in_group("soldier") and not body.is_dead and not is_dead:
		enabled = false
		soldier_manager.kill(body)
		die()

func die():
	game_manager.add_kill()
	is_dead = true
	
func update_health_bar():
	var ratio = clamp(life / max_life, 0.0, 1.0)

	# Base size of the red bar — assumed to be 1 unit wide initially
	var full_width = 1.0

	# Scale the red bar (optional, if static: skip this)
	red.scale.x = full_width
	red.position.x = 0.0  # center

	# Scale the green bar to match current health
	green.scale.x = ratio * full_width
	print(ratio , " " , full_width)

	# Offset green bar to stay left-aligned
	green.position.x = -0.5 * (1.0 - ratio) * full_width
