extends Area2D

@onready var label = $Label
@onready var size = $Sprite2D.texture.get_width() * scale
#var camera = $".".camera
#var spielbrett = $".".spielbrettxxx

var mouse_coll = false
var abgelegt = false
var dragging = false

func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventScreenDrag and mouse_coll:
		position = event.position
		print(label.text + "dragging")
		dragging = true
		GlobalConcepts.camera.screen_dragging_is_allowed = false
	elif event is InputEventScreenTouch and dragging:
		if not event.pressed: # wird losgelassen
			print(label.text + "dragging aus")
			GlobalConcepts.camera.screen_dragging_is_allowed = true
			dragging = false
		#get_parent().remove_child(self)
		#Main.spielbrett.add_child(self)
		
func _on_mouse_entered() -> void:
	var allowed = GlobalConcepts.camera.screen_dragging == false
	if allowed:
		mouse_coll = true
		pass
		print("Entered " + label.text)
	
	



func _on_mouse_exited() -> void:
	var allowed = GlobalConcepts.camera.screen_dragging == false
	if allowed:
		mouse_coll = false
		pass
		print("Exited " + label.text)
	
