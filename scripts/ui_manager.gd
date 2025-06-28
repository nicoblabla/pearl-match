extends CanvasLayer
class_name UIManager

@onready var counter = $VBoxContainer/Label

static var Instance

func _init():
	Instance = self

func update_text(real_count, display_count):
	if counter != null:
		counter.text = "Soldats: " + str(real_count)
