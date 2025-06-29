extends Control

@onready var popupContainer: VBoxContainer = $VBoxContainer
@onready var appStore = $AppStore
@onready var loading_icon = $AppStore/TextureRect/TextureRect2
@onready var flashScreen = $FlashScreen

@onready var godot_logo: TextureRect = $FlashScreen/CenterContainer/GodotLogo
@onready var jam_logo: TextureRect = $FlashScreen/CenterContainer/JamLogo


func _ready() -> void:
	appStore.visible = false
	flashScreen.visible = false


func app_store_pressed() -> void:
	var screen_height = get_viewport_rect().size.y
	var target_y = screen_height - appStore.size.y  # final Y position
	var start_y = screen_height  # off-screen

	appStore.visible = true
	appStore.position.y = start_y  # start off-screen

	var tween = create_tween()
	tween.tween_property(appStore, "position:y", target_y, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func on_get_pressed() -> void:
	$AppStore/TextureRect/ButtonGet.visible = false
	$AppStore/TextureRect/TextureRect.visible = true
	$AppStore/TextureRect/Loading.visible = true
	await get_tree().create_timer(2).timeout
	$AppStore/TextureRect/TextureRect.visible = false
	$AppStore/TextureRect/Loading.visible = false
	$AppStore/TextureRect/Open.visible = true

func on_open_pressed() -> void:
	var screen_height = get_viewport_rect().size.y
	var target_y = screen_height - flashScreen.size.y  # final Y position
	var start_y = screen_height  # off-screen

	flashScreen.visible = true
	flashScreen.position.y = start_y  # start off-screen
	
	# Définir la valeur initiale de modulate (complètement visible)
	godot_logo.modulate = Color(1, 1, 1, 0)
	jam_logo.modulate = Color(1, 1, 1, 0)

	var tween = create_tween()
	tween.tween_property(flashScreen, "position:y", target_y, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween = create_tween()
	tween.tween_property(godot_logo, "modulate:a", 1, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(godot_logo, "modulate:a", 0, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(jam_logo, "modulate:a", 1, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(jam_logo, "modulate:a", 0, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(GlobalManager.start_game)


func _on_fake_exit_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(popupContainer, "scale:x", 0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(popupContainer, "scale:y", 0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#await get_tree().create_timer(2).timeout
	tween.chain().tween_interval(1)
	tween.chain().tween_property(popupContainer, "scale:x", 1, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(popupContainer, "scale:y", 1, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
