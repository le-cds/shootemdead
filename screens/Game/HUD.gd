extends Node2D


####################################################################################
# Scene Objects

onready var life_bar: ProgressTiles = $MarginContainer/HBoxContainer/VBoxContainer/LifeBar
onready var bomb_progress: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/BombProgress
onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel


####################################################################################
# Setters

func set_max_lifes(lifes: int) -> void:
	life_bar.max_value = lifes


func set_lifes(lifes: int) -> void:
	life_bar.value = lifes


func set_max_bomb_progress(bomb: int) -> void:
	bomb_progress.max_value = bomb


func set_bomb_progress(bomb: int) -> void:
	bomb_progress.value = bomb


func set_score(score: int) -> void:
	var score_str: String = str(score)
	
	# We want to insert a space as thousands separator
	var insert_index: int = score_str.length() - 3
	while insert_index > 0:
		score_str = score_str.insert(insert_index, ".")
		insert_index -= 3
	
	score_label.text = score_str
