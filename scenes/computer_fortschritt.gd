extends Sprite2D

@onready var color_bar: ColorRect = $ColorBar
@onready var color_bar_max_breite = color_bar.size.x



func change_value(percent):
	var new_breite = color_bar_max_breite * percent
	color_bar.size.x = new_breite
	color_bar.color.r = 1 - percent
	color_bar.color.g = percent
	
