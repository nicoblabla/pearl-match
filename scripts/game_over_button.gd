extends Button

@onready var ui_manager = UIManager.Instance

func _pressed() -> void:
	ui_manager.try_again()
	
