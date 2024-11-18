extends Camera2D
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"


var is_pressed = false

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_pressed = true
				global_concepts.zug_beenden_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
			else:
				is_pressed = false
				global_concepts.zug_beenden_button.mouse_filter = Control.MOUSE_FILTER_STOP
	if event is InputEventMouseMotion:
		if is_pressed and not global_concepts.spielstein_is_dragged:
			position -= event.relative
			#print("camera poisiont", position)
