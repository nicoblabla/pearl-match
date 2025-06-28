extends Node3D

@onready var road_segment = $RoadStraight
@onready var road_size = road_segment.get_child(0).mesh.get_aabb().size * 20
@export var road_length: float = 10  # Length of the road segment
@export var min_gap: float = 0.01  # Minimum gap between buildings
@export var max_gap: float = 0.02  # Maximum gap between buildings
var buildings = [
	"res://models/buildings/large_buildingA.glb",
	"res://models/buildings/large_buildingB.glb",
	"res://models/buildings/large_buildingC.glb",
	"res://models/buildings/large_buildingD.glb",
	"res://models/buildings/large_buildingE.glb",
	"res://models/buildings/large_buildingF.glb",
	"res://models/buildings/large_buildingG.glb",
	"res://models/buildings/small_buildingA.glb",
	"res://models/buildings/small_buildingB.glb",
	"res://models/buildings/small_buildingC.glb",
	"res://models/buildings/small_buildingD.glb",
	"res://models/buildings/small_buildingE.glb",
	"res://models/buildings/small_buildingF.glb",
	"res://models/buildings/skyscraperA.glb",
	"res://models/buildings/skyscraperB.glb",
	"res://models/buildings/skyscraperC.glb",
	"res://models/buildings/skyscraperD.glb",
	"res://models/buildings/skyscraperE.glb",
	"res://models/buildings/skyscraperF.glb",
]

func _ready():
	for i in range(road_length):
		var road = road_segment.duplicate()
		road.position.x += (road_size.x) * i
		add_child(road)
	
	spawn_buildings()

func spawn_buildings():
	populate_side(Vector3(0, 0, -road_size.z + 10), true)  # Left side
	populate_side(Vector3(0, 0, road_size.z - 10), false)  # Right side

func populate_side(start_pos: Vector3, is_left: bool):
	var x_pos = 0.0  # Starting at X = 0

	while x_pos < road_length * 20:
		var building_path = buildings.pick_random()

		var building = load(building_path).instantiate()
		building.scale *= 20
		add_child(building)

		# Compute size
		var mesh_instance = building.get_child(0).get_child(0)
		var width = mesh_instance.mesh.get_aabb().size.x if mesh_instance and mesh_instance.mesh else 2.0
		
		building.position = start_pos + Vector3(x_pos, 0, 0)
		if not is_left:
			building.scale.z *= -1

		# Move to next position with a gap
		x_pos += width + randf_range(min_gap, max_gap)
