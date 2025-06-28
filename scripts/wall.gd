extends Node3D

@export var multiply= 1
@export var addition = 0
var walls = []
var enabled = true

@onready var label3d = $Label3D
@onready var area = $StaticBody3D
@onready var soldier_manager = SoldierManager.Instance

func _ready():
	area.body_entered.connect(on_trigger)

func set_value(m, a):
	multiply = m
	addition = a
	if multiply == 0 or multiply == 1:
		label3d.text = ("+" if addition > 0 else "-") + str(abs(addition))
	elif addition == 0:
		label3d.text = "×" + str(multiply)
	else:
		label3d.text = ("+" if addition > 0 else "-") + str(abs(addition)) + ", ×" + str(multiply)
		
func set_neighbors(ws):
	walls = ws

func on_trigger(body: Node) -> void:
	if enabled and body.is_in_group("soldier"):
		for wall in walls:
			print("Disabling wall: ", wall.name)
			wall.enabled = false
		var count = soldier_manager.real_count
		print("Wall triggered, current count: ", count, " addition: ", addition, " multiply: ", multiply)
		count += addition
		if multiply > 1:
			count *= multiply
		print("New count: ", count)
		soldier_manager.resize(count)
