extends Camera2D
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"


var is_pressed = false

var max_zoom = 2
var min_zoom = 0.4
var zoom_step = 0.1

func _ready() -> void:
	var spielbrett_size = preload("res://graphics/spielbrett.png").get_size()
	position = Vector2(spielbrett_size.x/2, spielbrett_size.y/2)

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_pressed = true
				global_concepts.zug_beenden_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
			else:
				is_pressed = false
				global_concepts.zug_beenden_button.mouse_filter = Control.MOUSE_FILTER_STOP
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if zoom.x >= min_zoom:
				zoom.x -= zoom_step
				zoom.y -= zoom_step
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if zoom.x <= max_zoom:
				zoom.x += zoom_step
				zoom.y += zoom_step
			
	if event is InputEventMouseMotion:
		if is_pressed and not global_concepts.spielstein_is_dragged:
			position -= event.relative
			
	
