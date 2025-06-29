extends CanvasLayer

static var Instance

@export var quit_counter : int = 0
@onready var quit_button: Button = $Panel/QuitButton
@onready var text: Label = $Panel/Text
@onready var texture_rect: TextureRect = $Panel/TextureRect

func _init():
	Instance = self
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

var can_process_escape = true
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		print("Escape pressed")
		can_process_escape = false

		if GlobalManager.State == GlobalManager.GameState.PAUSED:
			exit_pause()
		elif GlobalManager.State == GlobalManager.GameState.PLAYING:
			enter_pause()

		# Réinitialiser après un court délai
		await get_tree().create_timer(0.2).timeout
		can_process_escape = true

func enter_pause():
	if GlobalManager.State == GlobalManager.GameState.PLAYING:
		GlobalManager.change_state(GlobalManager.GameState.PAUSED)
		self.visible = true

func exit_pause():
	if GlobalManager.State == GlobalManager.GameState.PAUSED:
		GlobalManager.change_state(GlobalManager.GameState.PLAYING)
		self.visible = false

func _on_quit_button_pressed() -> void:
	print("pressed quit button")
	quit_counter += 1
	print(quit_counter)
	update_counter()

func update_counter():
	print(quit_counter)
	match quit_counter:
		1:
			text.text = "Please stay :( \nWe were having so much fun together"
		3 :
			text.text = "I beg you"
		5 :
			text.text = "PLEASE"
		10 :
			text.text = "Don't push me too far ..."
		15 :
			text.text = "Don't tell me I didn't warn you"
		20 :
			text.text = "I know who you are"
		22 :
			text.text = "Oh ? You don't believe me ? Well ..."
		23 :
			text.text = ""


func _on_resume_button_pressed() -> void:
	exit_pause()
