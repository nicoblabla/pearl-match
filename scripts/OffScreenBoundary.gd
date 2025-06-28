extends CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)

	# Obtenir le parent de l'objet détecté
	var parent = body.get_parent()

	# Vérifier si le parent existe et appartient au groupe "enemy"
	if parent != null :
		if parent.is_in_group("enemy") or parent.is_in_group("wall") or parent.is_in_group("road"):
			print(parent.name)
			# Supprimer le parent
			parent.queue_free()
			print("Parent supprimé")
	else:
		print("Le parent n'appartient pas au groupe ou n'existe pas")


func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area)

	# Obtenir le parent de l'objet détecté
	var parent = area.get_parent()

	# Vérifier si le parent existe et appartient au groupe "enemy"
	if parent != null :
		if parent.is_in_group("enemy") or parent.is_in_group("wall") or parent.is_in_group("road"):
			print(parent.name)
			# Supprimer le parent
			parent.queue_free()
			print("Parent supprimé")
	else:
		print("Le parent n'appartient pas au groupe ou n'existe pas")
