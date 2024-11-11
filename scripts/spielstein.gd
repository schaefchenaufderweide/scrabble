extends Area2D

@onready var label = $Label
@onready var size = $Sprite2D.texture.get_width() * scale


var is_touched = false
var abgelegt = false
var is_dragged = false
var snap_to_position = null

func _unhandled_input(event: InputEvent) -> void:	
	
	if event is InputEventScreenTouch:
		if not is_touched and event.pressed and not GlobalConcepts.spielstein_is_dragged:  # sofern nicht bereits einer gewählt ist
			is_touched = check_is_touched(event.position)  
			if is_touched:  # stein wird angeclickt
				print("touched")
				GlobalConcepts.spielstein_is_dragged = true				
				#GlobalConcepts.camera.screen_dragging_is_allowed = false
		
		if not event.pressed and is_touched: 
			print(label.text + " dragging aus")
			#GlobalConcepts.camera.screen_dragging_is_allowed = true
			GlobalConcepts.spielstein_is_dragged = false
			is_dragged = false				
			is_touched = false
			
	elif is_touched:
	
		
		position = event.position
		print(label.text + " is dragged")
		is_dragged = true	
		#get_parent().remove_child(self)
		#Main.spielbrett.add_child(self)

func check_is_touched(touch_pos):
	
	var dist = touch_pos.distance_to(position)
	if dist < size.x/2:
		return true
	else:
		return false
	
		#
#func _on_mouse_entered() -> void:
	#var allowed = GlobalConcepts.camera.screen_dragging == false
	#if allowed:
		#mouse_coll = true
		#pass
		#print("Entered " + label.text)
	#
	#
#
#
#
#func _on_mouse_exited() -> void:
	#var allowed = GlobalConcepts.camera.screen_dragging == false
	#if allowed:
		#mouse_coll = false
		#pass
		#print("Exited " + label.text)
	#
#
#
#func _on_area_entered(area: Area2D) -> void:
	#print(area, "entered")
	#pass # Replace with function body.
