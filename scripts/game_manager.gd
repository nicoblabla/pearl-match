extends Node3D

@onready var camera_container = $CameraContainer
@onready var soldier_manager = $Soldiers

func _process(delta: float) -> void:
	camera_container.position.x = soldier_manager.get_group_position()
