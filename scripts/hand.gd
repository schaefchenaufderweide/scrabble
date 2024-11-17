extends Node

@onready var stein_scene = preload("res://scenes/Spielstein.tscn")


@onready var hand_area = $HandArea

var steine = {}
var stein_positions = {}

func _ready() -> void:
	ziehe_steine()

func ziehe_steine():
	
	var anzahl_steine = GlobalGameSettings.anzahl_steine_pro_hand
	var abstand = GlobalGameSettings.abstand_zwischen_steinen
	
	
	for nr_stein in range(anzahl_steine):
		
		if not steine.get(nr_stein):
			
			var new_stein = stein_scene.instantiate()
			new_stein.name = "Stein " + str(nr_stein)
			add_child(new_stein)  
			var erste_x = hand_area.position.x - anzahl_steine/2 * (new_stein.size.x + abstand)
			var new_pos_x = erste_x + nr_stein * (new_stein.size.x + abstand)
			var new_pos_y = hand_area.position.y
			#print(new_stein.size)
			new_stein.position.x = randi_range(0, GlobalConcepts.screen_size.x)
			new_stein.position.y = GlobalConcepts.screen_size.y + 100
			var tween = create_tween()
			
			tween.tween_property(new_stein, "position", Vector2(new_pos_x, new_pos_y), 0.5)
			#new_stein.position.x = new_pos_x
			#new_stein.position.y = hand_area.position.y
			new_stein.pos_in_hand = nr_stein
			var random_buchstabe_nr = randi_range(0, len(GlobalConcepts.buchstaben_im_sackerl) - 1)
			var new_buchstabe = GlobalConcepts.buchstaben_im_sackerl.pop_at(random_buchstabe_nr)
			
			
			new_stein.label.text = new_buchstabe
			steine[nr_stein] = new_buchstabe
			
			stein_positions[new_stein] = Vector2(new_pos_x, new_pos_y)
			new_stein.wert = GlobalGameSettings.spielsteine_start[new_buchstabe]["Wert"]
			if self == GlobalConcepts.computer:
				new_stein.visible = false
