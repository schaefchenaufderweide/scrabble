extends Node



@onready var spielbrett = $"/root/Main/Spielbrett"
@onready var spielbereich_spielfelder = $"/root/Main/Spielbrett/Spielfelder"
@onready var spielbereich_abgelegte_steine = $"/root/Main/Spielbrett/AbgelegteSteine"
@onready var player = $"/root/Main/Player"
@onready var computer = $"/root/Main/Computer"


@onready var zug_beenden_button = $"/root/Main/UICanvasLayer/ZugBeenden"
@onready var zug_beenden_button_label = $"/root/Main/UICanvasLayer/ZugBeenden/Label"
@onready var computerdenkt_fortschrittanzeige: ColorRect = $"/root/Main/UICanvasLayer/ZugBeenden/ComputerdenktFortschrittanzeige"


var buchstaben_im_sackerl = create_buchstaben_im_sackerl()
@onready var camera = $"/root/Main/Camera2D"
@onready var main = $"/root/Main"
@onready var animation_player = $"/root/Main/AnimationPlayer"
#@onready var computerzug_sprite = $"/root/Main/UICanvasLayer/ComputerzugSprite"
@onready var computerzug: Node = $"/root/Main/Computerzug"

@onready var screen_size = get_viewport().size



var spielstein_is_dragged = false
var snap_field = null
var all_spielfelder = {}
#var allowed_richtungen = [[-1, 0], [1, 0], [0, -1], [0, 1]]

var wortliste_txt = load_wortliste()
#var moegliche_woerter_dict = load_moegliche_woerter_dict()


var an_der_reihe 

func _ready() -> void:
	#print("start global concepts")
	an_der_reihe = player
	#print(an_der_reihe)
func create_buchstaben_im_sackerl():
	var sackerl = []
	for buchstabe in GlobalGameSettings.spielsteine_start:
		
		var anzahl = GlobalGameSettings.spielsteine_start[buchstabe]["Anzahl"]
		
		for i in range(anzahl):
			sackerl.append(buchstabe)
	sackerl.shuffle()
	return sackerl

func load_wortliste():
	var wortliste_file = FileAccess.open("res://wortliste.txt", FileAccess.READ)
	return wortliste_file.get_as_text()
#
#func load_moegliche_woerter_dict():
	#moegliche_woerter_dict = {}
	#for buchstabe in GlobalGameSettings.allowed_letters:
		#var json = JSON.new()
		#var filename = "res://moegliche_woerter" + buchstabe + ".txt"
		#var moegliche_woerter_file = FileAccess.open(filename, FileAccess.READ)
		#var new_buchstaben_dict = JSON.parse_string(moegliche_woerter_file.get_as_text())
		#moegliche_woerter_dict[buchstabe] = new_buchstaben_dict
		##print(moegliche_woerter_dict)
	#
	#return moegliche_woerter_dict
	#

func save_wortliste():
	pass
#
#func save_moegliche_woerter_dict():
	#pass

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
			for spezial in GlobalGameSettings.spezialfelder:
				if [x, y] in GlobalGameSettings.spezialfelder[spezial]:
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
			all_spielfelder[[x,y]] = new_spielfeld
			
func get_belegte_felder(check_is_frisch_belegt):
	var group_alle_felder = get_tree().get_nodes_in_group("Spielfelder")
	var belegte_felder = {}
	var frisch_belegte_felder = []
	for feld_instance in group_alle_felder:
		
		if not check_is_frisch_belegt:
			
			if feld_instance.spielstein_auf_feld:
				belegte_felder[feld_instance.feld] = feld_instance.spielstein_auf_feld.label.text
		else:
			if feld_instance.frisch_belegt:
				frisch_belegte_felder.append(feld_instance.feld)
	if not check_is_frisch_belegt:				
				
		#print(belegte_felder)
		return belegte_felder
	else:
		return frisch_belegte_felder
#
#func get_frisch_belegte_felder():
	#var group_alle_felder = get_tree().get_nodes_in_group("Spielfelder")
	#var frisch_belegte_felder  = []
	#
	#for feld in group_alle_felder:
		#if feld.frisch_belegt:
			#frisch_belegte_felder.append(feld.feld)
	#return frisch_belegte_felder

func get_buchstaben_auf_feld(belegte_felder, feld):
	
	return belegte_felder[feld].label.text

func read_gelegte_woerter(is_computerzug):
	
	
	
	var belegte_felder = get_belegte_felder(false)
	# read horizontal
	var woerter_horizontal = []
	for y in range(GlobalGameSettings.anzahl_felder):
		var x = 0
		
		while x < GlobalGameSettings.anzahl_felder:
			var new_word = ""
			var beginn_feld = [x,y]
			var feld = [x, y]
			while feld in belegte_felder:
				new_word += belegte_felder[feld]
				x += 1
				feld = [x, y]
				
			if len(new_word) > 1:
				if is_computerzug:
					woerter_horizontal.append([new_word, beginn_feld, "horizontal"])
			
				else:
					woerter_horizontal.append(new_word)
			x += 1
	#print(woerter_horizontal)
	
	# read vertikal
	var woerter_vertikal = []
	for x in range(GlobalGameSettings.anzahl_felder):
		var y = 0
		
		while y < GlobalGameSettings.anzahl_felder:
			var new_word = ""
			var beginn_feld = [x,y]
			var feld = [x, y]
			while feld in belegte_felder:
				new_word += belegte_felder[feld]
				y += 1
				feld = [x, y]
			
			if len(new_word) > 1:
				if is_computerzug:
					woerter_vertikal.append([new_word, beginn_feld, "vertikal"])
				
				else:
					woerter_vertikal.append(new_word)
			y += 1
	
	return woerter_horizontal + woerter_vertikal
	
func get_allowed_spielfelder():
	var allowed_felder = []
	
	var belegte_felder = get_belegte_felder(false)
	var frisch_belegte_felder = get_belegte_felder(true)
		
	var allowed_x = []
	var allowed_y = []
	if len(frisch_belegte_felder) == 0:  
		allowed_x = range(0, 15)
		allowed_y = range(0, 15)
	elif len(frisch_belegte_felder) == 1: 
		
		allowed_x = [frisch_belegte_felder[0][0]]
		allowed_y = [frisch_belegte_felder[0][1]]
		
	elif frisch_belegte_felder[-2][1] == frisch_belegte_felder[-1][1]:
		
		allowed_y = [frisch_belegte_felder[0][1]]
	else:
		
		allowed_x = [frisch_belegte_felder[0][0]]
	
	
		
	if not all_spielfelder[[7,7]].spielstein_auf_feld:  # mitte wurde noch nicht platziert
		allowed_felder = [[7,7]]
		# dann ist NUR dieses erlaubt
	else:
			
		
		
		for feld in belegte_felder:
			#print("allowte richtungen", allowed_richtungen)
			
			for richtung in [[-1, 0], [1, 0], [0, -1], [0, 1]]:
				var checkfeld = [feld[0] + richtung[0], feld[1] + richtung[1]]
				
					
				if not checkfeld in belegte_felder and checkfeld in all_spielfelder:
					if richtung == [-1, 0] or richtung == [1, 0]:
						if checkfeld[1] in allowed_y:  # wenn horizontal check muss y stimmen
							if not checkfeld in allowed_felder:
								allowed_felder.append(checkfeld)
							
					elif richtung == [0, -1] or richtung == [0, 1]: # wenn vertikel muss x stimmen
						if checkfeld[0] in allowed_x:
							
							if not checkfeld in allowed_felder:
								allowed_felder.append(checkfeld)
	return allowed_felder
	
	
func set_allowed_spielfelder(allowed_felder):
	# setzen der spielfelder
	for feld in all_spielfelder:
		if feld in allowed_felder:
			all_spielfelder[feld].allowed = true
			all_spielfelder[feld].animation_player.play("allowed")
		else:
			all_spielfelder[feld].animation_player.stop()
			all_spielfelder[feld].allowed = false
		
		


func update_spielbrett(zug_erlaubt):
	for feld in all_spielfelder:  
		var spielfeld = all_spielfelder[feld]
		
		spielfeld.animation_player.stop()  # animation wird gestoppt
		
		if spielfeld.frisch_belegt:  # wurde in diesem zug mit spielstein belegt
			spielfeld.frisch_belegt = false  # wird gelöscht
			
			
			var spielstein_auf_feld = spielfeld.spielstein_auf_feld
			if zug_erlaubt:  # steine werden am feld fixiert
				spielstein_auf_feld.frisch_gelegt_sprite.visible = false
				spielstein_auf_feld.fixiert_sprite.visible = true
				spielstein_auf_feld.fixiert = true
				player.steine_dict[spielstein_auf_feld.pos_in_hand] = null
			else:  # steine wandern zurück zur hand
				var old_pos = spielstein_auf_feld.position - spielstein_auf_feld.offset_hand - camera.position
				
				spielstein_auf_feld.return_to_hand(old_pos)
				spielfeld.spielstein_auf_feld = null
				
				
		#GlobalConcepts.all_spielfelder[feld].frisch_belegt = false
		
	#print("nicht mehr frisch")
	
	
func zug_beenden():
	
	
	var gelegte_woerter = read_gelegte_woerter(false)
	#print(gelegte_woerter)
	var zug_erlaubt = true
	if not gelegte_woerter:
		zug_erlaubt = false
	
	# TODO NICHT GUT GENUG!!!! (WEIL WORT TEXT ALS RIESENLANGER STRING!)
	for wort in gelegte_woerter:
		#print(wort)
		if wort not in wortliste_txt:
			print(wort, " nicht in liste")
			zug_erlaubt = false
			break
	
	
		
	
	update_spielbrett(zug_erlaubt)
	if zug_erlaubt:
		change_an_der_reihe()
		
		
		
func change_an_der_reihe():
	if an_der_reihe == player:  # player WAR an der reihe, wechsel zu computer
		player.ziehe_steine()
		
		an_der_reihe = computer
		zug_beenden_button.disabled = true
		zug_beenden_button_label.text = "Computer denkt ..."
		computerdenkt_fortschrittanzeige.visible = true
		computerzug.aktiv = true
		computerzug.durchgang = 0
		animation_player.play("computer_denkt")
		#computerzug.init_word_array()
		
	else: # computer WAR an der reihe, wechsel zu player
		computer.ziehe_steine()
		
		an_der_reihe = player
		zug_beenden_button.disabled = false
		animation_player.play("RESET")
		zug_beenden_button_label.text = "Zug beenden"
		
		computerdenkt_fortschrittanzeige.visible = false
		
		computerzug.aktiv = false
		
