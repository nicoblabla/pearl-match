extends RigidBody3D


func _process(delta: float) -> void:
	pass
	
func _integrate_forces(state):
	if position.y < 0.1:
		global_position.y = 0.1
		linear_velocity.y = 0
