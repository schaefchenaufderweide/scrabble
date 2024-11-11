extends CanvasLayer

@onready var stein_scene = preload("res://scenes/Spielstein.tscn")


@onready var hand_area = $HandArea
#@onready var camera = $"../Camera2D"


var mouse_coll = false
var steine = {}

	
func ziehe_steine():
	
	var anzahl_steine = GlobalGameSettings.anzahl_steine_pro_hand
	var abstand = GlobalGameSettings.abstand_zwischen_steinen
	
	
	for nr_stein in range(anzahl_steine):
		
		if not steine.get(nr_stein):
			
			var new_stein = stein_scene.instantiate()
			add_child(new_stein)
			var erste_x = hand_area.position.x - anzahl_steine/2 * (new_stein.size.x + abstand)
			var new_pos_x = erste_x + nr_stein * (new_stein.size.x + abstand)
			
			#print(new_stein.size)
			new_stein.position.x = new_pos_x
			new_stein.position.y = hand_area.position.y
			
			var random_buchstabe_nr = randi_range(0, len(GlobalConcepts.buchstaben_im_sackerl) - 1)
			var new_buchstabe = GlobalConcepts.buchstaben_im_sackerl.pop_at(random_buchstabe_nr)
			
			
			new_stein.label.text = new_buchstabe
			steine[nr_stein] = new_buchstabe
			#
	


func _on_hand_area_mouse_entered() -> void:
	if not GlobalConcepts.camera.screen_dragging:
		#print("entered")
		mouse_coll = true
		GlobalConcepts.camera.screen_dragging_is_allowed = false
		


func _on_hand_area_mouse_exited() -> void:
	if not GlobalConcepts.camera.screen_dragging:
		#print("exited")
		mouse_coll = false
		GlobalConcepts.camera.screen_dragging_is_allowed = true
		pass # Replace with function body.
