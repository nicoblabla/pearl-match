extends Control

@onready var appStore = $AppStore
@onready var loading_icon = $AppStore/TextureRect/TextureRect2


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
	show_open()


func show_open():
	$AppStore/TextureRect/TextureRect.visible = true
	$AppStore/TextureRect/Loading.visible = true
	$AppStore/TextureRect/Open.visible = true
