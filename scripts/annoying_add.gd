extends Control

class_name AnnoyingAdd

enum AdState {
	NO_STARTED,
	BEFORE_AD,
	PLAYING_AD,
	WAITING_TO_SKIP,
	CLOSE_AD
}

static var Instance

signal ad_state_changed(old_state: AdState, new_state: AdState)

@export var STATE : AdState = AdState.NO_STARTED

@export var video_players : Array[VideoStreamPlayer] = []

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var ad_panel : Panel = $CanvasLayer/AdAnnoucement
@onready var ad_panel_text : Label = $CanvasLayer/AdAnnoucement/Label
@onready var progress_bar : ProgressBar = $CanvasLayer/ProgressBar
@onready var progress_label : Label = $CanvasLayer/ProgressBar/Label
@onready var skip_button : Button = $CanvasLayer/SkipButton

@onready var timer : Timer = $CanvasLayer/Timer
var time_left : int = 0
var ad_time : int = 10
var ad_time_progression : int = 0

var selected_player : VideoStreamPlayer

var random_timer : Timer

func _init():
	Instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_video_players();
	canvas_layer.visible = false
	
	GlobalManager.game_state_changed.connect(on_game_state_changed)
	# open_random_ad();
	
func on_game_state_changed(old_state: GlobalManager.GameState, new_state: GlobalManager.GameState) -> void:
	print("new state")
	match new_state:
		GlobalManager.GameState.PLAYING:
			random_timer = Timer.new()
			add_child(random_timer)
			random_timer.timeout.connect(open_random_ad)
			start_random_ad_timer()
		GlobalManager.GameState.PLAYING:
			random_timer.paused = false
		GlobalManager.GameState.PAUSED:
			random_timer.paused = true
# 		GlobalManager.GameState.PLAYING:
# 			if STATE == AdState.PLAYING_AD:
# 				start_ad()
# 		GlobalManager.GameState.PAUSED, GlobalManager.GameState.WIN, GlobalManager.GameState.GAME_OVER:
# 			if STATE == AdState.PLAYING_AD or STATE == AdState.WAITING_TO_SKIP:
# 				close_ad()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_C:
				if (STATE == AdState.NO_STARTED):
					open_random_ad()
			KEY_SPACE:
				_on_skip_button_pressed()

# Supposons que VideoContainer est un Node dans la scène
func get_video_players():
	var video_container = $CanvasLayer/VideoContainer
	for child in video_container.get_children():
		if child is VideoStreamPlayer:
			video_players.append(child)
	return video_players

func change_state(new_state: AdState) -> void:
	if STATE == new_state:
		return

	var old_state = STATE
	STATE = new_state
	ad_state_changed.emit(old_state, new_state)

func open_random_ad():
	canvas_layer.visible = true
	change_state(AdState.BEFORE_AD)
	GlobalManager.change_state(GlobalManager.GameState.AD)


	time_left = 5
	ad_panel_text.text = "Your ad will start in %d sec" % time_left
	timer.wait_time = 1
	timer.start()

	if video_players.size() == 0:
		return

	var random_index = randi_range(0, video_players.size() - 1)
	selected_player = video_players[random_index]

	progress_bar.max_value = ad_time
	progress_bar.value = 0
	progress_bar.visible = false

	skip_button.visible = false
	skip_button.disabled = true

	ad_time_progression = ad_time



func _on_timer_timeout() -> void:
	match STATE:
		AdState.NO_STARTED:
			return
		AdState.BEFORE_AD:
			time_left -= 1

			if time_left < 0:
				change_state(AdState.PLAYING_AD)
				start_ad()
				return

			ad_panel_text.text = "Your ad will start in %d sec" % time_left
			return
		AdState.PLAYING_AD:
			ad_time_progression -= 1
			progress_bar.value = ad_time - ad_time_progression
			progress_label.text = "Skip in %d sec" % ad_time_progression

			match ad_time_progression:
				7,6,5:
					timer.wait_time = 2;
				4,3,2,1:
					timer.wait_time = 3;

			if ad_time_progression < 0:
				change_state(AdState.WAITING_TO_SKIP)
				end_ad()

			return
		AdState.WAITING_TO_SKIP:
			return
		AdState.CLOSE_AD:
			close_ad()
			return


func _on_pub_finished() -> void:
	print("Finished playing ad")
	end_ad()

func start_ad() -> void:
	ad_panel.visible = false
	selected_player.play()
	progress_bar.visible = true

	skip_button.visible = true
	skip_button.disabled = true

func end_ad() -> void:
	progress_label.text = "Are you sure you want to skip the ad?"
	timer.stop()

	skip_button.visible = true
	skip_button.disabled = false

func close_ad() -> void:
	change_state(AdState.CLOSE_AD)
	selected_player.stop()
	ad_panel.visible = true
	progress_bar.visible = false
	skip_button.visible = false
	selected_player = null
	
	await get_tree().process_frame

	change_state(AdState.NO_STARTED)
	canvas_layer.visible = false

	start_random_ad_timer()
	GlobalManager.change_state(GlobalManager.GameState.PLAYING)



func _on_skip_button_pressed() -> void:
	if (STATE == AdState.WAITING_TO_SKIP):
		close_ad()

# Fonction qui démarre un timer qui déclenche de manière aléatoire une pub
func start_random_ad_timer(min_time: int = 30, max_time: int = 60) -> void:
	random_timer.wait_time = randi_range(min_time, max_time)
	random_timer.one_shot = true
	random_timer.start()
