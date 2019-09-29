extends Node2D

class_name House

const MEAN_RECT_WIDTH = 100
const RECT_WIDTH_VARIATION = 30

const MEAN_RECT_HEIGHT = 150
const RECT_HEIGHT_VARIATION = 50

var rnd = RandomNumberGenerator.new()

var Enemy = preload("res://tests/Enemy.tscn")
var enemy

func _ready():
	rnd.randomize()
	
	# Set a width and height for the building
	$Building.rect_size.x = MEAN_RECT_WIDTH + rnd.randi_range(-RECT_WIDTH_VARIATION, RECT_WIDTH_VARIATION)
	$Building.rect_size.y = MEAN_RECT_HEIGHT + rnd.randi_range(-RECT_HEIGHT_VARIATION, RECT_HEIGHT_VARIATION)
	$Building.rect_position.y = get_viewport_rect().size.y - $Building.rect_size.y
	
	$Building/VisibilityNotifier2D.rect.size.x = $Building.rect_size.x
	$Building/VisibilityNotifier2D.rect.size.y = $Building.rect_size.y
	
	# Spawn an enemy atop the house
	enemy = Enemy.instance()
	enemy.rect_position.y = $Building.rect_position.y - 40
	add_child(enemy)

func set_building_x(new_x):
	$Building.rect_position.x = new_x
	enemy.rect_position.x = new_x + 10

func get_building_x() -> int:
	return $Building.rect_position.x

func move_building(delta_x):
	$Building.rect_position.x -= delta_x
	enemy.rect_position.x -= delta_x

func get_building_width():
	return $Building.rect_size.x


func _on_VisibilityNotifier2D_screen_exited():
	print("Removing building")
	queue_free()
