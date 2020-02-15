extends Node2D

# Shows the splash screen while loading the main scene. Finally transitions
# smoothly to the main menu.

####################################################################################
# Scene Objects and State

onready var _splash: Node2D = $Splash
onready var _slideshow: Slideshow = $Splash/Slideshow
onready var _animation: AnimationPlayer = $Splash/AnimationPlayer
onready var _main_parent: Node2D = $MainParent

var _main_scene_loader: ResourceInteractiveLoader


####################################################################################
# Scene Lifecycle

func _ready() -> void:
	_slideshow.start()
	
	# Start loading the main scene
	_main_scene_loader = ResourceLoader.load_interactive("res://screens/Main/Main.tscn")


func _process(delta: float) -> void:
	# Once our main scene has finished loading, add it to the scene tree so it's
	# ready when the splash screen disappears.
	if _main_scene_loader != null and _main_scene_loader.poll() == ERR_FILE_EOF:
		_main_parent.add_child(_main_scene_loader.get_resource().instance())
		
		# Remove loader and disable processing for this node -- we're done!
		_main_scene_loader = null
		set_process(false)


####################################################################################
# Event Handling

func _on_Slideshow_slideshow_finished():
	# Fade out our splash screen and remove it
	_animation.play("FadeSplash")
	yield(_animation, "animation_finished")
	_splash.queue_free()
	
	# This would be dangerous if loading our main menu took long
	_main_parent.get_child(0).start()
