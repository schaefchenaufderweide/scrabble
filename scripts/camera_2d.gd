extends Camera2D


var is_pressed = false

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_pressed = true
				GlobalConcepts.zug_beenden_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
			else:
				is_pressed = false
				GlobalConcepts.zug_beenden_button.mouse_filter = Control.MOUSE_FILTER_STOP
	if event is InputEventMouseMotion:
		if is_pressed and not GlobalConcepts.spielstein_is_dragged:
			position -= event.relative
			#print("camera poisiont", position)
