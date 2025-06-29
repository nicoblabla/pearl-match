extends Node

enum GameState {
	INTRO,
	START,
	SETUP,
	MENU,
	PLAYING,
	PAUSED,
	AD,
	WIN,
	GAME_OVER
	}

signal game_state_changed(old_state: GameState, new_state: GameState)

@export var State: GameState = GameState.INTRO

var current_scene = null

func change_state(new_state: GameState) -> void:
	if State == new_state:
		return

	var old_state = State
	State = new_state
	game_state_changed.emit(old_state, new_state)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_scene = get_tree().current_scene
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_game() -> void:
	change_state(GameState.START)
	goto_scene("res://Game.tscn")

func pause_game() -> void:
	if State == GameState.PLAYING:
		change_state(GameState.PAUSED)

func resume_game() -> void:
	if State == GameState.PAUSED:
		change_state(GameState.PLAYING)

func start_ad() -> void:
	if State == GameState.PLAYING:
		change_state(GameState.AD)
		AnnoyingAdd.Instance.open_random_ad()

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
