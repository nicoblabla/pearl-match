extends Node3D

@onready var camera_container = $CameraContainer
@onready var soldier_manager = $Soldiers
@onready var road_segment_prefab = load("res://prefabs/road_segment.tscn")
@onready var roads = $Roads

var roadList = []
var num_segments = 5
var segment_length = 10 * 20 

func _ready() -> void:
	for i in range(num_segments):
		var road = road_segment_prefab.instantiate()
		road.position.x = i * segment_length
		roads.add_child(road)
		roadList.push_back(road)

func _process(delta: float) -> void:
	camera_container.position.x = soldier_manager.get_leader_position()
	if camera_container.position.x > roadList[0].position.x + segment_length * 2:
		# Remove the first road segment
		var first_segment = roadList.pop_front()
		var last_segment = roadList[-1]
		
		# Move the segment forward
		first_segment.position.x = last_segment.position.x + segment_length
		roadList.append(first_segment)
