# enemy_spawn_data.gd
class_name EnemySpawnData
extends Resource

@export var enemy_scene: PackedScene
@export_range(0.0, 1.0, 0.01) var spawn_chance: float = 0.5
@export var max_health: float = 100.
@export var scale: float = 1.
