extends Node2D

const HOUSE_SPACING = 20

var speed = 50
var displacement = 0

var last_house = null

var enemies_survived = 0
var enemies_killed = 0

var house_scene = preload("res://scenes/House.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add houses to the scene until it's full
	var screen_width = get_viewport_rect().size.x
	var x = HOUSE_SPACING
	
	while x < screen_width:
		var house = spawn_house(x)
		x += house.get_building_width() + HOUSE_SPACING

func _process(delta):
	displacement += delta * speed
	if displacement >= 1:
		var displacement_rounded = floor(displacement)
		displacement -= displacement_rounded
	
		for house in get_tree().get_nodes_in_group("houses"):
			house.move_building(displacement_rounded)
		
		# Check if there is enough space for a new house
		if last_house:
			var screen_width = get_viewport_rect().size.x
			
			if last_house.get_building_x() + last_house.get_building_width() + HOUSE_SPACING <= screen_width + 10:
				spawn_house(last_house.get_building_x() + last_house.get_building_width() + HOUSE_SPACING)
	
	$Label.text = str(enemies_killed) + " killed\n" + str(enemies_survived) + " survived"
	
	
func spawn_house(x: int) -> House:
	print("Spawning house...")
	var house = house_scene.instance()
	$Rectangles.add_child(house)
	house.set_building_x(x)
	house.add_to_group("houses")
	
	# Listen to when enemies die and survive
	house.enemy.connect("died", self, "_on_Enemy_died")
	house.enemy.connect("survived", self, "_on_Enemy_survived")
	
	last_house = house
	return house


func _on_Enemy_died():
	enemies_killed += 1
	

func _on_Enemy_survived():
	enemies_survived += 1 
