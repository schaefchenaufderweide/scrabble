extends Node

@onready var spielbrett = $Spielbrett
@onready var spielbrett_size = $Spielbrett/CollisionShape2D.shape.get_rect().size
@onready var player_hand = $HandPlayer
var buchstaben_im_sackerl = create_buchstaben_im_sackerl()


func _ready() -> void:
	init_spielfeld()
	
	player_hand.ziehe_steine(buchstaben_im_sackerl) 

func init_spielfeld():
	var spielfeld_scene = preload("res://scenes/Spielfeld.tscn")
	var anzahl_felder = GlobalGameSettings.anzahl_felder
	var abstand = GlobalGameSettings.abstand_zwischen_steinen
	for y in range(anzahl_felder):
		for x in range(anzahl_felder):
			var new_spielfeld = spielfeld_scene.instantiate()
			spielbrett.add_child(new_spielfeld)
			var erste_x = spielbrett_size.x/2 - anzahl_felder/2 * new_spielfeld.size.x
			var new_position_x = erste_x + x * (new_spielfeld.size.x + abstand)
			new_spielfeld.position.x = new_position_x
			# TODO NICHT SICHTBAR!!!
			
			
func _process(delta: float) -> void:
	pass


func create_buchstaben_im_sackerl():
	
	return ["C", "B", "D", "X", "Y", "O", "P", "R", "S"]
