extends Node



@onready var spielbrett = $"/root/Main/Spielbrett"
@onready var spielbereich_spielfelder = $"/root/Main/Spielbrett/Spielfelder"
@onready var spielbereich_abgelegte_steine = $"/root/Main/Spielbrett/AbgelegteSteine"
@onready var player_hand = $"/root/Main/Hand"
var buchstaben_im_sackerl = create_buchstaben_im_sackerl()
@onready var camera = $"/root/Main/Camera2D"
@onready var main = $"/root/Main"

@onready var screen_size = get_viewport().size

var spezialfelder = {"dreifacher Wortwert": [[0,0], [7,0], [14, 0], [0, 7], [14,7], [0, 14], [7,14], [14,14]],
"doppelter Wortwert": [[1,1],[2,2], [3,3], [4,4], [10, 4], [11, 3], [12,2], [13,1],[1, 13], [2,12], [3,11], [4,10], [10,10], [11,11], [12,12], [13,13]],
"dreifacher Buchstabenwert": [[5,1], [9,1], [1,5], [5,5], [9,5], [13,5], [1, 9], [5,9], [9,9],[13,9], [5,13], [9,13]],
"doppelter Buchstabenwert": [[3,0], [11,0], [0,3],[6,2],[8,2],[7,3],[2,6],[6,6],[8,6],[12,6],[3,7],[11,7],[2,8],[6,8],[8,8],[12,8],[0,11],[7,11],[14,11],[6,12],[8,12],[3,14],[11,14]],
"Mitte": [[7,7]]}

var spielstein_is_dragged = false
var snap_field = null


func create_buchstaben_im_sackerl():
	var buchstaben_im_sackerl = []
	for buchstabe in GlobalGameSettings.spielsteine_start:
		
		var anzahl = GlobalGameSettings.spielsteine_start[buchstabe]["Anzahl"]
		
		for i in range(anzahl):
			buchstaben_im_sackerl.append(buchstabe)
	buchstaben_im_sackerl.shuffle()
	return buchstaben_im_sackerl


func init_spielfeld():
	#var spielbrett_size = spielbrett.size
	
	var spielfeld_scene = preload("res://scenes/Spielfeld.tscn")
	var spielfeld_size = preload("res://graphics/spielfeld.png").get_size()
	
	var anzahl_felder = GlobalGameSettings.anzahl_felder
	var abstand = GlobalGameSettings.abstand_zwischen_steinen
	
	var erste_x = spielbrett.position.x - anzahl_felder/2 * (spielfeld_size.x + abstand)
	var erste_y = spielbrett.position.y - anzahl_felder/2 * (spielfeld_size.y + abstand)
	for y in range(anzahl_felder):
		for x in range(anzahl_felder):
			
			var new_spielfeld = spielfeld_scene.instantiate()
			new_spielfeld.name = "Spielfeld (" + str(x) + "x" + str(y) + ")"
			spielbereich_spielfelder.add_child(new_spielfeld)
			var spezial_markierung = null
			for spezial in spezialfelder:
				if [x, y] in spezialfelder[spezial]:
					spezial_markierung = spezial
					break
			if spezial_markierung == "dreifacher Wortwert":
				new_spielfeld.dreifacher_wortwert.visible = true
			elif spezial_markierung == "doppelter Wortwert":
				new_spielfeld.doppelter_wortwert.visible = true
			elif spezial_markierung == "dreifacher Buchstabenwert":
				new_spielfeld.dreifacher_buchstabenwert.visible = true
			elif spezial_markierung == "doppelter Buchstabenwert":
				new_spielfeld.doppelter_buchstabenwert.visible = true
			elif spezial_markierung == "Mitte":
				new_spielfeld.mitte.visible = true
			
			var new_position_x = erste_x + x * (spielfeld_size.x + abstand)
			var new_position_y = erste_y + y * (spielfeld_size.y + abstand)
			new_spielfeld.position.x = new_position_x
			new_spielfeld.position.y = new_position_y
			new_spielfeld.feld = [x, y]

func read(ausgangsfeld, belegte_felder):
		var neue_woerter = []
		
		for richtung in ["horizontal", "vertikal"]:
			
			var new_wort = ""
		
			while ausgangsfeld in belegte_felder:
				new_wort += belegte_felder[ausgangsfeld]
				if richtung == "horizontal":
					ausgangsfeld = [ausgangsfeld[0] + 1, ausgangsfeld[1]]
				else:
					ausgangsfeld = [ausgangsfeld[0], ausgangsfeld[1] + 1]
			
		
		
		return neue_woerter
	
func find_wortanfaenge_felder(belegte_felder):
	var felder_wortanfaenge = []
	
	for feld in belegte_felder:
		for richtung in [[0, -1], [-1, 0]]:
			var checkfeld = [feld[0] + richtung[0], feld[1] + richtung[1]]
			if checkfeld not in belegte_felder:
				felder_wortanfaenge.append(feld)
	print(felder_wortanfaenge)
	return felder_wortanfaenge
		
	# TODO HIER WEITER DENKEN!

func read_gelegte_woerter():
	
	var group_alle_felder = get_tree().get_nodes_in_group("Spielfelder")
	
	var belegte_felder = {}
	
	for feld in group_alle_felder:
		if feld.belegt:
			belegte_felder[feld.feld] = feld.belegt.label.text
	
	var wortanfaenge_felder = find_wortanfaenge_felder(belegte_felder)
	
	var all_woerter = []
	for x in range(GlobalGameSettings.anzahl_felder):
		for y in range(GlobalGameSettings.anzahl_felder):
			var feld = [x, y]
			if feld in wortanfaenge_felder:
				all_woerter += read(feld, belegte_felder)
				#all_woerter.append(read(feld, "vertikal", belegte_felder))
	print(all_woerter)
	#
	## read horizontal
	#for belegt in belegte_felder:
		#var x = belegt[0]
		#var y = belegt[1]
		#
		#var new_wort = 
		
			
	
	for feld in group_alle_felder:
		if feld.belegt:
			print(feld.feld, ": ", feld.belegt.label.text)
	

func _on_zug_beenden_button_up() -> void:
	var gelegte_woerter = read_gelegte_woerter()
	
	
