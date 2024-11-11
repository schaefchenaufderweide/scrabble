extends Camera2D

#@onready var hand_player = $"../HandPlayer"
#var screen_dragging = false
#var screen_dragging_is_allowed = true

	

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventScreenDrag:
		#if event.pressed:
		if not GlobalConcepts.spielstein_is_dragged:
			position -= event.relative
				#screen_dragging = true
		
