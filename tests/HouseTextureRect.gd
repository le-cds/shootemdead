extends TextureRect

const MEAN_RECT_WIDTH = 100
const RECT_WIDTH_VARIATION = 30

const MEAN_RECT_HEIGHT = 150
const RECT_HEIGHT_VARIATION = 50

func _ready():
	# Set a width and height for the building
	rect_size.x = MEAN_RECT_WIDTH + randi() % (2 * RECT_WIDTH_VARIATION) - RECT_WIDTH_VARIATION
	rect_size.y = MEAN_RECT_HEIGHT + randi() % (2 * RECT_HEIGHT_VARIATION) - RECT_HEIGHT_VARIATION
