extends Node2D

onready var _slideshow: Slideshow = $Slideshow

func _ready():
	_slideshow.start()
