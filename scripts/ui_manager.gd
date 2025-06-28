extends CanvasLayer
class_name UIManager

@onready var counter = $VBoxContainer/Label

static var Instance

func _init():
	Instance = self

func update_text(display_count, real_count):
	if counter != null:
		counter.text = "Soldat: " + str(real_count) + "\ndisplayed: " + str(display_count)
