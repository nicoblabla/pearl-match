extends CanvasLayer
class_name UIManager

@onready var counter = $VBoxContainer/Panel/VBoxContainer/Label
@onready var game_over = $GameOver

static var Instance

func _init():
	Instance = self

func update_text(real_count, display_count):
	if counter != null:
		counter.text = "Soldats: " + str(max(0, real_count))

func show_game_over():
	game_over.visible = true
	
func try_again():
	get_tree().reload_current_scene()
