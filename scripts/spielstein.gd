extends Area2D

@onready var label = $Label
@onready var size = $Sprite2D.texture.get_width() * scale
@onready var camera = get_parent().camera
var mouse_coll = false


func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventScreenDrag and mouse_coll:
		position = event.position
		print("dragging")
		camera.screen_dragging_is_allowed = false
	elif event is InputEventScreenTouch and not event.pressed:
		print("aus")
		camera.screen_dragging_is_allowed = true

func _on_mouse_entered() -> void:
	var allowed = camera.screen_dragging == false
	if allowed:
		mouse_coll = true
		pass
		print("Entered " + label.text)
	
	



func _on_mouse_exited() -> void:
	var allowed = camera.screen_dragging == false
	if allowed:
		mouse_coll = false
		pass
		print("Exited " + label.text)
	
