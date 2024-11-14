extends Area2D

@onready var label = $Label
@onready var size = $Sprite2D.texture.get_width() * scale


var offset_hand = Vector2(-GlobalConcepts.screen_size.x/2, -GlobalConcepts.screen_size.y/2)
var is_touched = false
var abgelegtes_feld = false
var is_pressed = false

func _input(event: InputEvent) -> void:	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and is_touched:
				# spielstein wird hand entnommen
				
				is_pressed = true
				GlobalConcepts.spielstein_is_dragged = true
				if get_parent() == GlobalConcepts.player_hand:
					GlobalConcepts.player_hand.remove_child(self)
					GlobalConcepts.spielbereich_abgelegte_steine.add_child(self)
				if abgelegtes_feld:
					abgelegtes_feld.belegt = null
					abgelegtes_feld.animation_player.play("select")
				
				position = event.position + offset_hand + GlobalConcepts.camera.position
				
			elif not event.pressed and is_touched:
				# spielstein wird losgelassen
				is_pressed = false
				GlobalConcepts.spielstein_is_dragged = false
				print("snap field: ", GlobalConcepts.snap_field)
				if GlobalConcepts.snap_field:
					position = GlobalConcepts.snap_field.position
					GlobalConcepts.snap_field.belegt = self
					abgelegtes_feld = GlobalConcepts.snap_field
					abgelegtes_feld.animation_player.stop()
				else:
					get_parent().remove_child(self)
					GlobalConcepts.player_hand.add_child(self)
					position = GlobalConcepts.player_hand.stein_positions[self]
				
	if event is InputEventMouseMotion:
		if is_pressed:
			
			position = event.position + offset_hand + GlobalConcepts.camera.position
			
func _on_mouse_entered() -> void:
	if not GlobalConcepts.spielstein_is_dragged:
		# berührt spielstein
		is_touched = true
	
func _on_mouse_exited() -> void:
	if not is_pressed:
		is_touched = false
		
