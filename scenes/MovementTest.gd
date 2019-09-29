extends Node2D

const HOUSE_SPACING = 20

var house_scene = preload("res://scenes/House.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add houses to the scene until it's full
	var screen_width = get_viewport_rect().size.x
	var x = HOUSE_SPACING
	
	while x < screen_width:
		var house = house_scene.instance()
		add_child(house)
		house.set_building_x(x)
		x += house.get_building_width() + HOUSE_SPACING
		print("Added building")
