extends Node

@onready var stein_scene = preload("res://scenes/Spielstein.tscn")
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"


@onready var hand_area = $HandArea

var steine_dict = {}
var stein_hand_positions = {}


func _ready() -> void:
	ziehe_steine()

func ziehe_steine():
	
	var anzahl_steine = GlobalGameSettings.anzahl_steine_pro_hand
	var abstand = GlobalGameSettings.abstand_zwischen_steinen
	
	
	for nr_stein in range(anzahl_steine):
		
		if not steine_dict.get(nr_stein):
			
			var new_stein = stein_scene.instantiate()
			new_stein.name = "Stein " + str(nr_stein)
			add_child(new_stein)  
			var erste_x = hand_area.position.x - anzahl_steine/2 * (new_stein.size.x + abstand)
			var new_pos_x = erste_x + nr_stein * (new_stein.size.x + abstand)
			var new_pos_y = hand_area.position.y
			#print(new_stein.size)
			new_stein.position.x = randi_range(0, global_concepts.screen_size.x)
			new_stein.position.y = global_concepts.screen_size.y + 100
			var tween = create_tween()
			
			tween.tween_property(new_stein, "position", Vector2(new_pos_x, new_pos_y), 0.5)
			#new_stein.position.x = new_pos_x
			#new_stein.position.y = hand_area.position.y
			new_stein.pos_in_hand = nr_stein
			var random_buchstabe_nr = randi_range(0, len(global_concepts.buchstaben_im_sackerl) - 1)
			var new_buchstabe = global_concepts.buchstaben_im_sackerl.pop_at(random_buchstabe_nr)
			
			
			new_stein.label.text = new_buchstabe
			steine_dict[nr_stein] = new_stein
			
			stein_hand_positions[new_stein] = Vector2(new_pos_x, new_pos_y)
			new_stein.wert = GlobalGameSettings.spielsteine_start[new_buchstabe]["Wert"]
			if self == global_concepts.computer:
				new_stein.visible = false
	print(self, get_buchstaben())

func get_buchstaben():
	var buchstaben = []
	for stein_nr in steine_dict:
		buchstaben.append(steine_dict[stein_nr].label.text)
	return buchstaben
