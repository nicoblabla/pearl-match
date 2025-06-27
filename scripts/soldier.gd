extends RigidBody3D


func _process(delta: float) -> void:
	pass
	
func _integrate_forces(state):
	if position.y < 1.2:
		global_position.y = 1.2
		linear_velocity.y = 0
