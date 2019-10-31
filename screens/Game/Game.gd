extends State


####################################################################################
# Constants, Scene Objects, State

# The enemy scene we'll be spawning.
const ENEMY_SCENE: PackedScene = preload("res://assets/Enemy/Enemy.tscn")
# Maximum number of lifes.
const MAX_LIFES := 5
# Number of enemies to kill until we get a free bomb
const MAX_BOMB_PROGRESS := 20


onready var _hud: HUD = $HUD


# Current score.
var _score: int
# Number of lifes left.
var _lifes: int
# Progress to the next bomb.
var _bomb_progress: int
# Speed at which the world is moving.
var _game_speed: int


####################################################################################
# Scene Lifecycle

func _ready() -> void:
	_hud.set_max_lifes(MAX_LIFES)
	_hud.set_max_bomb_progress(MAX_BOMB_PROGRESS)


func _process(delta) -> void:
	# If the user presses Escape, exit the pause menu
	if is_running() and Input.is_action_just_pressed("ui_cancel"):
		_pause()


func _notification(what) -> void:
	# Pause if we lose focus during the game
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		_pause()


####################################################################################
# State Lifecycle

func state_started(prev_state: State) -> void:
	.state_started(prev_state)
	
	# Reset our state and update the HUD
	_score = 0
	_lifes = MAX_LIFES
	_bomb_progress = 0
	_game_speed = Constants.BASE_SPEED_GAME
	
	_update_hud()


####################################################################################
# Game State Handling

# Pauses the game.
func _pause() -> void:
	transition_push(Constants.STATE_MENU_PAUSE)


# Game over!
func _game_over() -> void:
	# TODO There should be more here
	transition_pop_to_root()


####################################################################################
# Enemy Handling

# Initiates the enemy spawning process.
func _building_spawned(scene: Node) -> void:
	# We're only interested if the game is running
	if not (is_running() and scene is Building):
		return
	
	var building: Building = scene as Building
	
	var enemy: Enemy = ENEMY_SCENE.instance()
	building.add_child(enemy)
	call_deferred("_init_enemy", building, enemy)


# Finishes the enemy spawning process.
func _init_enemy(building: Building, enemy: Enemy) -> void:
	enemy.set_spawn_location(building.random_enemy_position())
	enemy.connect("enemy_left", self, "_enemy_left", [], CONNECT_ONESHOT)


# Called whenever an enemy dies or survives. This will update the score, lifes,
# bomb progress etc.
func _enemy_left(enemy: Enemy, survived: bool) -> void:
	if survived:
		_lifes -= 1
		if _lifes == 0:
			_game_over()
	else:
		_bomb_progress += 1
		_score += 1000
		_game_speed += 4
		
		ScrollSpeedController.interpolate_base_speed(_game_speed, 5)
	
	_update_hud()


####################################################################################
# HUD Handling

func _update_hud() -> void:
	_hud.set_score(_score)
	_hud.set_lifes(_lifes)
	_hud.set_bomb_progress(_bomb_progress)
