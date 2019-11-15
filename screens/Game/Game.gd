extends State


####################################################################################
# Constants, Scene Objects, State

# The enemy scene we'll be spawning.
const ENEMY_SCENE: PackedScene = preload("res://assets/Enemy/Enemy.tscn")
# Maximum number of lifes.
const MAX_LIFES := 5
# Bomb progress killing an enemy will earn.
const BOMB_PROGRESS := 1
# Number of enemies to kill until we get a free bomb.
const MAX_BOMB_PROGRESS := 20
# Score without multiplier that killing an enemy earns the player.
const BASE_SCORE_PER_ENEMY := 1000
# Game speed increase killing an enemy will yield.
const GAME_SPEED_INCREMENT := 4


var score_multiplier_scene = preload("res://screens/Game/ScoreMultiplier.tscn")


onready var _hud: HUD = $HUD
onready var _animation_player: AnimationPlayer = $AnimationPlayer


# Current score.
var _score: int
# Number of lifes left.
var _lifes: int
# Progress to the next bomb.
var _bomb_progress: int
# Speed at which the world is moving.
var _game_speed: int

# ID we'll give to the next enemy to spawn
var _next_enemy_id: int
# ID of the most recent enemy that was killed.
var _last_killed_enemy_id: int
# The current score multiplier, as determined by how many enemies we killed in a row.
var _score_multiplier: int


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

func state_activated() -> void:
	.state_activated()
	
	# Reset our state and update the HUD
	_score = 0
	_lifes = MAX_LIFES
	_bomb_progress = 0
	_game_speed = Constants.BASE_SPEED_GAME
	
	_next_enemy_id = 1
	_last_killed_enemy_id = -1
	_score_multiplier = 0
	
	# Applying the game speed is only necessary during development, where we may
	# skip the game intro which usually takes care of this
	ScrollSpeedController.set_base_speed(_game_speed)
	
	_update_hud()
	_animation_player.play("FadeHUD")


func state_deactivated() -> void:
	.state_deactivated()
	
	_remove_enemies()


####################################################################################
# Game State Handling

# Pauses the game.
func _pause() -> void:
	transition_push(Constants.STATE_MENU_PAUSE)


# Game over!
func _game_over() -> void:
	_animation_player.play_backwards("FadeHUD")
	yield(_animation_player, "animation_finished")
	
	_remove_enemies()
	
	# Pass the score to the game over screen as a paramter
	transition_push(Constants.STATE_GAME_OVER, { Constants.STATE_GAME_OVER_SCORE: _score })


####################################################################################
# Enemy Handling

# Initiates the enemy spawning process.
func _building_spawned(scene: Node) -> void:
	# We're only interested if the game is running
	if not (is_running() and _lifes > 0 and scene is Building):
		return
	
	var building: Building = scene as Building
	
	var enemy: Enemy = ENEMY_SCENE.instance()
	building.add_child(enemy)
	call_deferred("_init_enemy", building, enemy)


# Finishes the enemy spawning process.
func _init_enemy(building: Building, enemy: Enemy) -> void:
	enemy.id = _next_enemy_id
	_next_enemy_id += 1
	
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
		_update_score_multiplier(enemy)
		
		_bomb_progress += BOMB_PROGRESS
		_score += BASE_SCORE_PER_ENEMY * _score_multiplier
		_game_speed += GAME_SPEED_INCREMENT
		
		ScrollSpeedController.interpolate_base_speed(_game_speed, 5)
		
		_show_score_multiplier(enemy, _score_multiplier)
	
	_update_hud()


# Tells all remaining enemies to survive.
func _remove_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group(Constants.GROUP_ENEMIES):
		(enemy as Enemy).survive(false, true)


# Updates the score multiplier after the given enemy was killed. The idea is that
# killing enemies with consecutive IDs increases the score multiplier by one.
# Killing one out of order resets the multiplier.
func _update_score_multiplier(enemy: Enemy) -> void:
	if enemy.id == _last_killed_enemy_id + 1:
		_score_multiplier += 1
	else:
		_score_multiplier = 1
	
	_last_killed_enemy_id = enemy.id


# Shows a score multiplier above the given enemy.
func _show_score_multiplier(enemy: Enemy, multiplier: int) -> void:
	var scene = score_multiplier_scene.instance()
	self.add_child(scene)
	scene.animate(multiplier, enemy.get_top_center())


####################################################################################
# Bomb Handling

# Throws and explodes a bomb, if possible.
func _throw_bomb() -> void:
	if _bomb_progress >= MAX_BOMB_PROGRESS:
		# Gather all enemies and find their min and max ID (important for the score
		# multiplier)
		var min_enemy_id := _next_enemy_id
		var max_enemy_id := 0
		var enemies = []
		for object in get_tree().get_nodes_in_group(Constants.GROUP_ENEMIES):
			var enemy: Enemy = object as Enemy
			if enemy.is_alive() and enemy.is_on_screen():
				min_enemy_id = min(min_enemy_id, enemy.id)
				max_enemy_id = max(max_enemy_id, enemy.id)
				enemies.append(enemy)
		
		if not enemies.empty():
			# Reset the score multiplier if the player skipped an enemy
			if min_enemy_id > _last_killed_enemy_id + 1:
				_score_multiplier = 0
			_last_killed_enemy_id = max_enemy_id
			
			_score_multiplier += enemies.size()
			
			# Update our stats
			_score += enemies.size() * BASE_SCORE_PER_ENEMY * _score_multiplier
			_bomb_progress = 0
			
			# Kill all enemies, but don't notify us -- we'll update the score and things
			# ourselves here. Also, show multipliers
			for enemy in enemies:
				_show_score_multiplier(enemy, _score_multiplier)
				enemy.die(false)
			
			$AnimationPlayer.play("BombExplosion")
			
			_update_hud()


####################################################################################
# HUD Handling

func _update_hud() -> void:
	_hud.set_score(_score)
	_hud.set_lifes(_lifes)
	_hud.set_bomb_progress(_bomb_progress)


func _on_HUD_bomb_requested():
	_throw_bomb()
