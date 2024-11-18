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

var spezialfelder = {"dreifacher Wortwert": [[0,0], [7,0], [14, 0], [0, 7], [14,7], [0, 14], [7,14], [14,14]],
"doppelter Wortwert": [[1,1],[2,2], [3,3], [4,4], [10, 4], [11, 3], [12,2], [13,1],[1, 13], [2,12], [3,11], [4,10], [10,10], [11,11], [12,12], [13,13]],
"dreifacher Buchstabenwert": [[5,1], [9,1], [1,5], [5,5], [9,5], [13,5], [1, 9], [5,9], [9,9],[13,9], [5,13], [9,13]],
"doppelter Buchstabenwert": [[3,0], [11,0], [0,3],[6,2],[8,2],[7,3],[2,6],[6,6],[8,6],[12,6],[3,7],[11,7],[2,8],[6,8],[8,8],[12,8],[0,11],[7,11],[14,11],[6,12],[8,12],[3,14],[11,14]],
"Mitte": [[7,7]]}

var spielstein_is_dragged = false
var snap_field = null
var all_spielfelder = {}
#var allowed_richtungen = [[-1, 0], [1, 0], [0, -1], [0, 1]]
var file = FileAccess.open("res://wortliste.txt", FileAccess.READ)
var wortliste = file.get_as_text()
var an_der_reihe 

func _ready() -> void:
	print("start global concepts")
	an_der_reihe = player
	print(an_der_reihe)
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
			all_spielfelder[[x,y]] = new_spielfeld
			
func get_belegte_felder():
	var group_alle_felder = get_tree().get_nodes_in_group("Spielfelder")
	var belegte_felder = {}
	
	for feld in group_alle_felder:
		if feld.spielstein_auf_feld:
			belegte_felder[feld.feld] = feld.spielstein_auf_feld.label.text
			
	return belegte_felder

func get_frisch_belegte_felder():
	var group_alle_felder = get_tree().get_nodes_in_group("Spielfelder")
	var frisch_belegte_felder  = []
	
	for feld in group_alle_felder:
		if feld.frisch_belegt:
			frisch_belegte_felder.append(feld.feld)
	return frisch_belegte_felder


func read_gelegte_woerter():
	
	
	var belegte_felder = get_belegte_felder()
	# read horizontal
	var woerter_horizontal = []
	for y in range(GlobalGameSettings.anzahl_felder):
		var x = 0
		
		while x < GlobalGameSettings.anzahl_felder:
			var new_word = ""
			var feld = [x, y]
			while feld in belegte_felder:
				new_word += belegte_felder[feld]
				x += 1
				feld = [x, y]
			if len(new_word) > 1:
				woerter_horizontal.append(new_word)
			x += 1
	#print(woerter_horizontal)
	
	# read vertikal
	var woerter_vertikal = []
	for x in range(GlobalGameSettings.anzahl_felder):
		var y = 0
		
		while y < GlobalGameSettings.anzahl_felder:
			var new_word = ""
			var feld = [x, y]
			while feld in belegte_felder:
				new_word += belegte_felder[feld]
				y += 1
				feld = [x, y]
			if len(new_word) > 1:
				woerter_vertikal.append(new_word)
			y += 1
	#print(woerter_vertikal)
	return woerter_horizontal + woerter_vertikal
	
func set_allowed_spielfelder():
	var allowed_felder = []
	# legerichtung eruieren
	var belegte_felder = get_belegte_felder()
	var frisch_belegte_felder = get_frisch_belegte_felder()
	#print("frisch belegt", frisch_belegte_felder)
	#print("gesamt gelegt", belegte_felder)
		
	var allowed_x = []
	var allowed_y = []
	if len(frisch_belegte_felder) == 0:  # 0 -> alle richtungen erlaubt und alle gelegten steine erlaubt
		#allowed_richtungen = [[-1, 0], [1, 0], [0, -1], [0, 1]]  # alle richtungen
		allowed_x = range(0, 15)
		allowed_y = range(0, 15)
	elif len(frisch_belegte_felder) == 1: # 1 > alle richtungen erlaubt, nur frisch belegte felder
		#allowed_richtungen = [[-1, 0], [1, 0], [0, -1], [0, 1]]  # alle richtungen
		allowed_x = [frisch_belegte_felder[0][0]]
		allowed_y = [frisch_belegte_felder[0][1]]
		
	elif frisch_belegte_felder[-2][1] == frisch_belegte_felder[-1][1]:
		#allowed_richtungen = [[-1, 0], [1, 0]] # horizontal
		allowed_y = [frisch_belegte_felder[0][1]]
	else:
		#allowed_richtungen = [[0, -1], [0, 1]] # vertikal
		allowed_x = [frisch_belegte_felder[0][0]]
	
	# alle spielfelder anfangs auf nicht allowed setzen
	
	#print("allowed x:", allowed_x)
	#print("allowed y:", allowed_y)
	for feld in all_spielfelder:
		all_spielfelder[feld].allowed = false
		all_spielfelder[feld].animation_player.stop()
		
	if not all_spielfelder[[7,7]].spielstein_auf_feld:  # mitte wurde noch nicht platziert
		allowed_felder = [[7,7]]
		#all_spielfelder[[7,7]].allowed = true
		#all_spielfelder[[7,7]].animation_player.play("allowed")
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
							#all_spielfelder[checkfeld].allowed = true
							
							#all_spielfelder[checkfeld].animation_player.play("allowed")
					elif richtung == [0, -1] or richtung == [0, 1]: # wenn vertikel muss x stimmen
						if checkfeld[0] in allowed_x:
							#all_spielfelder[checkfeld].allowed = true
							#all_spielfelder[checkfeld].animation_player.play("allowed")
							if not checkfeld in allowed_felder:
								allowed_felder.append(checkfeld)
	#print("erlaubte")
	for all in allowed_felder:
		#print("erlaubt", all)
		all_spielfelder[all].allowed = true
		all_spielfelder[all].animation_player.play("allowed")
		


func update_spielbrett(zug_erlaubt):
	for feld in all_spielfelder:  # GD SCRIPT VERGISST (?) 
		var spielfeld = all_spielfelder[feld]
		
		spielfeld.animation_player.stop()  # animation wird gestoppt
		
		if spielfeld.frisch_belegt:  # wurde in diesem zug mit spielstein belegt
			spielfeld.frisch_belegt = false  # wird gelöscht
			
			
			var spielstein_auf_feld = spielfeld.spielstein_auf_feld
			if zug_erlaubt:  # steine werden am feld fixiert
				spielstein_auf_feld.frisch_gelegt_sprite.visible = false
				spielstein_auf_feld.fixiert_sprite.visible = true
				player.steine[spielstein_auf_feld.pos_in_hand] = null
			else:  # steine wandern zurück zur hand
				var old_pos = spielstein_auf_feld.position - spielstein_auf_feld.offset_hand - camera.position
				
				spielstein_auf_feld.return_to_hand(old_pos)
				spielfeld.spielstein_auf_feld = null
				
				
		#GlobalConcepts.all_spielfelder[feld].frisch_belegt = false
		
	#print("nicht mehr frisch")
	
	
func zug_beenden():
	
	
	var gelegte_woerter = read_gelegte_woerter()
	
	var zug_erlaubt = true
	if not gelegte_woerter:
		zug_erlaubt = false
		
	for wort in gelegte_woerter:
		print(wort)
		if wort not in wortliste:
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
		animation_player.play("computer_denkt")
	else: # computer WAR an der reihe, wechsel zu player
		computer.ziehe_steine()
		
		an_der_reihe = player
		zug_beenden_button.disabled = false
		zug_beenden_button_label.text = "Zug beenden"
		computerdenkt_fortschrittanzeige.visible = false
		animation_player.stop()
		
