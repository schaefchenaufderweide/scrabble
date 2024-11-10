extends Camera2D

#@onready var hand_player = $"../HandPlayer"
var screen_dragging = false
var screen_dragging_is_allowed = true

	

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventScreenDrag:
		
		if screen_dragging_is_allowed:
			position -= event.relative
			screen_dragging = true
	
	elif event is InputEventScreenTouch and not event.pressed:
		print("aus")
		screen_dragging = false
