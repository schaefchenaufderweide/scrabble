extends Area2D

@onready var label = $Label
@onready var size = $SpriteFrischGelegt.texture.get_width() * scale
@onready var frisch_gelegt_sprite = $SpriteFrischGelegt
@onready var fixiert_sprite = $SpriteFixiert
@onready var global_concepts: Node =  $"/root/Main/GlobalConcepts"

@onready var offset_hand = Vector2(-global_concepts.screen_size.x/2, -global_concepts.screen_size.y/2)
var is_touched = false
var abgelegtes_feld = false
var is_pressed = false
var wert
var fixiert = false
var pos_in_hand 

func _input(event: InputEvent) -> void:	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and is_touched:
				# spielstein wird genommen
				
				is_pressed = true
				global_concepts.spielstein_is_dragged = true
				if get_parent() == global_concepts.player:  # aus hand entnommen
					#print("aus hand entnommen")
					global_concepts.player.remove_child(self)
					global_concepts.spielbereich_abgelegte_steine.add_child(self)
				else:
					#print("aus spielfeld entnommen")
					abgelegtes_feld.spielstein_auf_feld = null
					#abgelegtes_feld.animation_player.play("select")
					abgelegtes_feld.frisch_belegt = false
					abgelegtes_feld.select_rect.visible = false
				#print("check allowed spielfelder")
				global_concepts.set_allowed_spielfelder()
					
				position = event.position + offset_hand + global_concepts.camera.position
				
			elif not event.pressed and is_touched:
				# spielstein wird losgelassen
				is_pressed = false
				global_concepts.spielstein_is_dragged = false
				#print("snap field: ", GlobalConcepts.snap_field)
				if global_concepts.snap_field: # stein wird auf spielbrett gelegt
					position = global_concepts.snap_field.position
					global_concepts.snap_field.spielstein_auf_feld = self
					abgelegtes_feld = global_concepts.snap_field
					abgelegtes_feld.select_rect.visible = false
					
					abgelegtes_feld.frisch_belegt = true
					
					global_concepts.set_allowed_spielfelder()
				else: # stein geht zurück zur hand
					return_to_hand(event.position)
					
					
	if event is InputEventMouseMotion:
		if is_pressed:
			
			position = event.position + offset_hand + global_concepts.camera.position

func return_to_hand(old_position):
	
	get_parent().remove_child(self)
	global_concepts.player.add_child(self)
	position = old_position
	var tween = create_tween()
	#tween.position = position
	tween.tween_property(self, "position", Vector2(global_concepts.player.stein_positions[self]), 0.5)
	#position = GlobalConcepts.player_hand.stein_positions[self]
		
func _on_mouse_entered() -> void:
	if not global_concepts.spielstein_is_dragged and not fixiert:
		# berührt spielstein
		is_touched = true
	
func _on_mouse_exited() -> void:
	if not is_pressed:
		is_touched = false
		
