extends Node2D

const MEAN_RECT_WIDTH = 100
const RECT_WIDTH_VARIATION = 30

const MEAN_RECT_HEIGHT = 150
const RECT_HEIGHT_VARIATION = 50

var rnd = RandomNumberGenerator.new()

func _ready():
	rnd.randomize()
	
	# Set a width and height for the building
	$Building.rect_size.x = MEAN_RECT_WIDTH + rnd.randi_range(-RECT_WIDTH_VARIATION, RECT_WIDTH_VARIATION)
	$Building.rect_size.y = MEAN_RECT_HEIGHT + rnd.randi_range(-RECT_HEIGHT_VARIATION, RECT_HEIGHT_VARIATION)
	$Building.rect_position.y = get_viewport_rect().size.y - $Building.rect_size.y

func set_building_x(new_x):
	$Building.rect_position.x = new_x

func get_building_width():
	return $Building.rect_size.x
