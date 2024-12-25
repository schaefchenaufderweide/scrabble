extends Node



@onready var spielbrett = $"/root/Main/Spielbrett"
@onready var spielbereich_spielfelder = $"/root/Main/Spielbrett/Spielfelder"
@onready var spielbereich_abgelegte_steine = $"/root/Main/Spielbrett/AbgelegteSteine"
@onready var player = $"/root/Main/Player"
@onready var computer = $"/root/Main/Computer"
@onready var player_punkte_label = $"/root/Main/UICanvasLayer/LabelPunktePlayer"
@onready var computer_punkte_label = $"/root/Main/UICanvasLayer/LabelPunkteComputer"

@onready var zug_beenden_button = $"/root/Main/UICanvasLayer/ZugBeenden"
@onready var zug_beenden_button_label = $"/root/Main/UICanvasLayer/ZugBeenden/Label"
@onready var computerdenkt_fortschrittanzeige: ColorRect = $"/root/Main/UICanvasLayer/ZugBeenden/ComputerdenktFortschrittanzeige"
@onready var wortliste = $"/root/Main/Wortliste"

var buchstaben_im_sackerl = create_buchstaben_im_sackerl()
@onready var camera = $"/root/Main/Camera2D"
@onready var main = $"/root/Main"
@onready var animation_player = $"/root/Main/AnimationPlayer"
#@onready var computerzug_sprite = $"/root/Main/UICanvasLayer/ComputerzugSprite"
@onready var computerzug: Node = $"/root/Main/Computerzug"

@onready var screen_size = get_viewport().size
@onready var offset_screen_mitte = Vector2(screen_size.x/2, screen_size.y/2)
@onready var ui_info_label: Node = $"/root/Main/UICanvasLayer/UIInfo"
@onready var popup_menu: Node = $"/root/Main/UICanvasLayer/PopUpMenu"
var button_scene = preload("res://scenes/MenuButton.tscn")


var punkte_labels = {}
var punkte_scene = preload("res://scenes/PunkteLabel.tscn")

var brett_ist_leer 
var dragged_stein = null
var spielstein_is_dragged = false
var snap_field = null
var all_spielfelder = {}

var spielfeld_is_locked = false
#var waiting_for_option_pick = false
var last_round = false
var an_der_reihe 
var wortliste_txt
var wortliste_dict 

func _ready() -> void:
	wortliste_txt = wortliste.get_wortliste()
	wortliste_dict = wortliste.get_wortliste_dict(wortliste_txt)
	
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
				belegte_felder[feld_instance.feld] = feld_instance.spielstein_auf_feld.label_buchstabe.text
		else:
			if feld_instance.frisch_belegt:
				frisch_belegte_felder.append(feld_instance.feld)
	if not check_is_frisch_belegt:				
				
		#print("belegte felder :", belegte_felder)
		return belegte_felder
	else:
		#print("frisch belegte felder: ", frisch_belegte_felder)
		return frisch_belegte_felder

func read_gelegte_woerter(computerzug_zu_testende_buchstaben):
	
	var belegte_felder = get_belegte_felder(false)
	var frisch_gelegte_felder = get_belegte_felder(true)
	
	for feld in computerzug_zu_testende_buchstaben:
		frisch_gelegte_felder.append(feld)
		belegte_felder[feld] = computerzug_zu_testende_buchstaben[feld]
	
	#var new_words = []
	var alle_woerter = []
	
	for richtung in ["horizontal", "vertikal"]:
		
		for stelle_fix in range(GlobalGameSettings.anzahl_felder):
			var stelle_variabel = 0
			while stelle_variabel < GlobalGameSettings.anzahl_felder:
				var new_word = ""
				var beginn_feld 
				if richtung == "horizontal":
					beginn_feld = [stelle_variabel, stelle_fix]
					
				else:
					beginn_feld = [stelle_fix, stelle_variabel]
				var feld = beginn_feld
				var is_new_word = false
				var buchstaben_dict = {}
				while feld in belegte_felder:
					if feld in frisch_gelegte_felder:
						is_new_word = true
					new_word += belegte_felder[feld]
					buchstaben_dict[feld] = belegte_felder[feld]
					stelle_variabel += 1
					if richtung == "horizontal":
						feld = [stelle_variabel, stelle_fix]
					
					else:
						feld = [stelle_fix, stelle_variabel]
				if len(new_word) > 1:
					if is_new_word:
						#print(new_word, " ist beim readen als neues wort erkannt worden!")
						alle_woerter.append([new_word, buchstaben_dict, true])
					else:
						#print(new_word, " ist beim readen als altes wort erkannt worden!")
						alle_woerter.append([new_word, buchstaben_dict, false])
				stelle_variabel += 1
	
	return alle_woerter
	
	#
func get_allowed_spielfelder():
	
	
	
	
	var belegte_felder = get_belegte_felder(false)
	var frisch_belegte_felder = get_belegte_felder(true)
	change_zug_beenden_label(frisch_belegte_felder)
	if not is_frisch_gelegt_valid(frisch_belegte_felder, belegte_felder):
		print("keine gültigen allowed felder!")
		return []
	
	var allowed_felder = []
	
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
	
	
	
	if not belegte_felder and not frisch_belegte_felder:  # mitte wurde noch nicht platziert
		#print("keine mitte")
		allowed_felder = [[7,7]]
		# dann ist NUR dieses erlaubt
	else:
			
		
		
		for feld in belegte_felder:
			#print("allowte richtungen", allowed_richtungen)
			
			for richtung in [[-1, 0], [1, 0], [0, -1], [0, 1]]:
				var checkfeld = [feld[0] + richtung[0], feld[1] + richtung[1]]
				#print("checking ", checkfeld)
				
				if not checkfeld in belegte_felder and checkfeld in all_spielfelder:
					if richtung == [-1, 0] or richtung == [1, 0]:
						if checkfeld[1] in allowed_y:  # wenn horizontal check muss y stimmen
							if is_valid(checkfeld, frisch_belegte_felder, belegte_felder):
								if not checkfeld in allowed_felder:
									allowed_felder.append(checkfeld)
							
					elif richtung == [0, -1] or richtung == [0, 1]: # wenn vertikel muss x stimmen
						if checkfeld[0] in allowed_x:
							if is_valid(checkfeld, frisch_belegte_felder, belegte_felder):
								if not checkfeld in allowed_felder:
									allowed_felder.append(checkfeld)
	#print(allowed_felder)
	return allowed_felder

func is_frisch_gelegt_valid(frisch_belegte_felder, belegte_felder):
	
	
	if len(frisch_belegte_felder) == 0:
		return true
	
	
	if not [7,7] in frisch_belegte_felder and not [7,7] in belegte_felder:
		print("mitte nicht besetzt")
		return false
	
	if len(frisch_belegte_felder) == 1:  # prüfen, ob das eine frische benachbart mit belegten ist
		
		var checkfeld = frisch_belegte_felder[0]
		if checkfeld == [7,7]:  # mitte besetzt mit allererstem
			return true
		for richtung in [[1,0], [-1,0], [0,1], [0,-1]]:
			var test_feld_check = [checkfeld[0] + richtung[0], checkfeld[1] + richtung[1]]
			if test_feld_check in belegte_felder:
				return true
				
		
		return false
	
	var check_reihe_oder_spalte = null
	var check_reihe_oder_spalte_nr = null
	if frisch_belegte_felder[-2][1] == frisch_belegte_felder[-1][1]:
		check_reihe_oder_spalte = "reihe"
		check_reihe_oder_spalte_nr = frisch_belegte_felder[-2][1]
	elif frisch_belegte_felder[-2][0] == frisch_belegte_felder[-1][0]:
		check_reihe_oder_spalte = "spalte"
		check_reihe_oder_spalte_nr = frisch_belegte_felder[-2][0]
	else:  # letzten zwei sind nicht in einer reihe oder spalte
		return false
	
	var reihenfolge = []
	for frisch in frisch_belegte_felder:
		
		# es müssen alle frisch gelegten die gleiche reihe bzw. spalte haben
		if check_reihe_oder_spalte == "reihe":
			if not frisch[1] == check_reihe_oder_spalte_nr:
				return false
			
		else:
			if not frisch[0] == check_reihe_oder_spalte_nr:
				return false
		reihenfolge.append(frisch)
		
	
	# check frisch gelegt miteinander verbunden - reihenfolge vollständig
	var richtung
	if check_reihe_oder_spalte == "reihe":
		reihenfolge.sort_custom(func(a, b): return a[0] < b[0])
		richtung = [1, 0]
	else:
		reihenfolge.sort_custom(func(a, b): return a[1] < b[1])
		richtung = [0, 1]
	var test_feld = reihenfolge[0]
	while not test_feld == reihenfolge[-1]:
		test_feld = [test_feld[0] + richtung[0], test_feld[1] + richtung[1]]
		if test_feld not in frisch_belegte_felder and test_feld not in belegte_felder: 
			#es besteht eine lücke in der reihenfolge - frisch gelegte sind nicht durchgehend verbunden!
			return false
	return true
	
				
	
	


func is_valid(checkfeld, frisch_belegte_felder, belegte_felder):
	"""
	prüft, ob checkfeld mit einem frisch belegten feld benachbart ist. 
	auch erlaubt ist, wenn es noch keine frisch belegten felder gibt
	"""
	if not frisch_belegte_felder:
		return true
	for feld in frisch_belegte_felder:
		#var benachbart = false
		var test_feld
		for richtung in [[1,0], [-1,0], [0,1], [0,-1]]:
			test_feld = [feld[0] + richtung[0], feld[1] + richtung[1]]
			if test_feld == checkfeld:
				return true
			while test_feld in belegte_felder:
				# prüft weiter in die richtung, ob ein frisch 
				test_feld = [test_feld[0] + richtung[0], test_feld[1] + richtung[1]]
				if test_feld == checkfeld:
					return true
	return false
	
	
	
func set_allowed_spielfelder(allowed_felder):
	#var frisch_belegte_felder = get_belegte_felder(true)
	# setzen der spielfelder
	for feld in all_spielfelder:
		all_spielfelder[feld].animation_player.play("RESET")
		if feld in allowed_felder:
			all_spielfelder[feld].allowed = true
			all_spielfelder[feld].animation_player.play("allowed")
		else:
			all_spielfelder[feld].animation_player.stop()
			all_spielfelder[feld].allowed = false
			
		
		


func update_spielbrett(player_zug_erlaubt):
	for feld in all_spielfelder:  
		var spielfeld = all_spielfelder[feld]
		
		spielfeld.animation_player.stop()  # animation wird gestoppt
		
		if spielfeld.frisch_belegt:  # wurde in diesem zug mit spielstein belegt
			spielfeld.frisch_belegt = false  # wird gelöscht
			
			
			var spielstein_auf_feld = spielfeld.spielstein_auf_feld
			if player_zug_erlaubt:  # steine werden am feld fixiert
				spielstein_auf_feld.frisch_gelegt_sprite.visible = false
				spielstein_auf_feld.fixiert_sprite.visible = true
				spielstein_auf_feld.fixiert = true
				player.steine_dict[spielstein_auf_feld.pos_in_hand] = null
			else:  # steine wandern zurück zur hand
				var old_pos = spielfeld_pos_to_mouse_pos(spielstein_auf_feld.position)
				
				spielstein_auf_feld.return_to_hand(old_pos)
				spielfeld.spielstein_auf_feld = null
				
				
		#GlobalConcepts.all_spielfelder[feld].frisch_belegt = false
		
	#print("nicht mehr frisch")
	
	
func player_zug_beenden(spielsteine_to_reverse_to_fragezeichen_dict=null):
	#print("player zug beenden")
	var player_zug_erlaubt 
	
	
	var frisch_gelegt = get_belegte_felder(true)
	var allowed_felder = get_allowed_spielfelder()
	var gelegte_woerter = read_gelegte_woerter([])
	
	if zug_beenden_button_label.text == "Steine tauschen":
		assert(not frisch_gelegt)
		player_zug_erlaubt = true
		player.steine_tauschen()
	elif zug_beenden_button_label.text == "Passen":
		player_zug_erlaubt = true
		if not buchstaben_im_sackerl:
			last_round = true
	elif zug_beenden_button_label.text == "Spielende":
		print("Spielende!")
		pass
		# TODO!!!!!
		
	
	else:
		player_zug_erlaubt = is_zug_gueltig(allowed_felder, gelegte_woerter)
	
	if spielfeld_is_locked:# and waiting_for_option_pick:  # warten auf optionen wählen
		return
		
	update_spielbrett(player_zug_erlaubt)
	
	
	
	if player_zug_erlaubt:
		var reverse_zellen = []
		if spielsteine_to_reverse_to_fragezeichen_dict:
			reverse_zellen = spielsteine_to_reverse_to_fragezeichen_dict.values()
		var ergebnis = get_punkte(gelegte_woerter, frisch_gelegt, reverse_zellen)
		var new_punkte = ergebnis[0]
		var new_labels = ergebnis[1]
		player.add_punkte(new_punkte)#player.punkte += new_punkte
		for lab in new_labels:
			punkte_labels[lab] = new_labels[lab]
		
		change_an_der_reihe()
	else:
		allowed_felder = get_allowed_spielfelder()
		set_allowed_spielfelder(allowed_felder)
		if spielsteine_to_reverse_to_fragezeichen_dict:
			for stein in spielsteine_to_reverse_to_fragezeichen_dict:
				stein.label_buchstabe.text = "?"

func get_punkte(gelegte_woerter, frisch_gelegte_felder, fragezeichen_zellen):
	var neue_woerter = []
	
	for wort_lst in gelegte_woerter:
		var is_new = wort_lst[2]
		if is_new:
			#print(wort_lst[0], " ist neu!")
			neue_woerter.append(wort_lst)
	
	if len(neue_woerter) > 1:
		var punkte_woerter = []
		for wort in neue_woerter:
			var ergebnis = get_punkte_wort(wort, [], frisch_gelegte_felder, fragezeichen_zellen)
			punkte_woerter.append([ergebnis[1], wort])
		
		punkte_woerter.sort_custom(func(a, b): return a[0] > b[0])
		neue_woerter = []
		for wort_lst in punkte_woerter:
			neue_woerter.append(wort_lst[1])
	
	var punkte = 0
	var bereits_abgerechnet = []
	var punkte_label_wort = {}
	for wort in neue_woerter:
		
		var ergebnis = get_punkte_wort(wort, bereits_abgerechnet, frisch_gelegte_felder, fragezeichen_zellen)
		bereits_abgerechnet = ergebnis[0]
		punkte += ergebnis[1]
		punkte_label_wort = ergebnis[2]
	#print("Player erhält ", punkte + punkte_fuer_bereits_gelegte_felder, " Punkte")
	return [punkte, punkte_label_wort] 
	
	
func get_punkte_wort(wort_lst, bereits_abgerechnet, frisch_gelegte_felder, fragezeichen_zellen):
	var wort_wert_bonus_faktor = 1
	
	var punkte_insgesamt = 0
	var buchstaben_dict = wort_lst[1]
	var alle_buchstaben_bonus = 0
	var new_punkte_labels_fuer_wort = {}
	var alle_buchstaben_bonus_gelegt = false
	if len(frisch_gelegte_felder) == GlobalGameSettings.anzahl_steine_pro_hand:
		alle_buchstaben_bonus = 50
		
	for feld in buchstaben_dict:
		var new_punkte_labels_fuer_feld = []
		var buchstabe = buchstaben_dict[feld]
		var buchstaben_wert_bonus_faktor = 1
		if feld in frisch_gelegte_felder and not feld in bereits_abgerechnet:
			if feld in GlobalGameSettings.spezialfelder["dreifacher Wortwert"]:
				wort_wert_bonus_faktor = 3
				new_punkte_labels_fuer_feld.append("Wort x 3!")
			elif feld in GlobalGameSettings.spezialfelder["doppelter Wortwert"]:
				wort_wert_bonus_faktor = 2
				new_punkte_labels_fuer_feld.append("Wort x 2!")
			if feld in GlobalGameSettings.spezialfelder["dreifacher Buchstabenwert"]:
				buchstaben_wert_bonus_faktor = 3
				#print(feld, " ist dreifacher Buchstabenwert")
			elif feld in GlobalGameSettings.spezialfelder["doppelter Buchstabenwert"]:
				buchstaben_wert_bonus_faktor = 2
				#print(feld, " ist doppelter Buchstabenwert")
			bereits_abgerechnet.append(feld)
		if feld in fragezeichen_zellen:
			buchstaben_wert_bonus_faktor = 0  # wurde ursprünglich als fragezeichen gelegt
		var new_punkte = GlobalGameSettings.spielsteine_start[buchstabe]["Wert"] * buchstaben_wert_bonus_faktor
		new_punkte_labels_fuer_feld.append(new_punkte * wort_wert_bonus_faktor)
		if alle_buchstaben_bonus and not alle_buchstaben_bonus_gelegt:
			new_punkte_labels_fuer_feld.append("Alle Buchstaben + 50!")
			alle_buchstaben_bonus_gelegt = true
		
		punkte_insgesamt += new_punkte
			
		new_punkte_labels_fuer_wort[feld] = new_punkte_labels_fuer_feld
	
	
	punkte_insgesamt *= wort_wert_bonus_faktor
	punkte_insgesamt += alle_buchstaben_bonus
	#print(punkte, " punkte für ", wort_lst[0])
	return [bereits_abgerechnet, punkte_insgesamt, new_punkte_labels_fuer_wort]
		
	
	
func create_new_punkte_labels():
	
	for feld in punkte_labels:
		
		var position
		var offset
		
		
		position = all_spielfelder[feld].position
		offset = all_spielfelder[feld].size/2
	
		for punkte_text in punkte_labels[feld]:
			
			#var punkte_text = punkte_labels[feld]
			var new_punkte_label = punkte_scene.instantiate()
			new_punkte_label.position = position - offset
			new_punkte_label.text = str(punkte_text)
			
			spielbereich_spielfelder.add_child(new_punkte_label)
			var tween = create_tween()
			var max_size
			var new_position = null
			#var new_rotation = 0
			
			if typeof(punkte_text) == TYPE_INT:
				max_size = 1 + punkte_text/2
			else:   # keine punkte angeführt, sondern text
				max_size = 3
				new_position = new_punkte_label.position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
				var new_rotation = randi_range(-45,45)
				new_punkte_label.rotation = deg_to_rad(new_rotation)
				
			var dauer = 5
			tween.tween_property(new_punkte_label, "scale", Vector2(max_size, max_size), dauer).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
			tween.parallel().tween_property(new_punkte_label, "modulate:a", 0, dauer).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
			if new_position:
				tween.parallel().tween_property(new_punkte_label, "position", new_position, dauer)
				#tween.parallel().tween_property(new_punkte_label, "rotation", new_rotation, dauer).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			new_punkte_label.timer.wait_time = dauer
			new_punkte_label.timer.start()
	punkte_labels = {}
	
func is_zug_gueltig(allowed_felder, gelegte_woerter):
	
	if not allowed_felder:  # zug ungültig!
		#print("zug ungültig! falsch gelegt")
		return false
	
	if not gelegte_woerter:
		return false  # keine wörter gelegt!
		
	for wort_lst in gelegte_woerter:
		var wort = wort_lst[0]
		if "?" in wort:
			var wort_dict = wort_lst[1]
			var allright = false
			for zelle in wort_dict:
				if wort_dict[zelle] == "?":
					allright = true
					break
			assert(allright) 
			
			create_wortvorschlaege_fragezeichen(wort, wort_dict)
			
			return false
		
		if wort.strip_edges() not in wortliste_dict:
			#print(wort, " nicht in liste (weitere wurden nicht geprüft)")
			return false
		#else:
			#print(wort, " in liste")
	return true
	
func create_wortvorschlaege_fragezeichen(wort_txt, wort_dict):
	var pattern = wort_txt.replace("?", "[A-Z]") # nur ganzes solches wort
	#var pattern = ".{0,1}" + wort_anfrage.replace("?", ".") + ".{0,1}" # nur ganzes solches wort
	var matches_txt_lst = regex_operation(pattern)
	if not matches_txt_lst:
		return
	open_popup(matches_txt_lst, "Fragezeichen ersetzen", wort_dict)
	
	
		
func change_an_der_reihe():
	spielfeld_is_locked = true
	create_new_punkte_labels()
	if an_der_reihe == player:  # player WAR an der reihe, wechsel zu computer
		player.ziehe_steine()
		
		
		an_der_reihe = computer
		computerzug.restart()
		zug_beenden_button.disabled = true
		zug_beenden_button_label.text = "Computer denkt ..."
		#animation_player.play("computer_denkt")
		
		#player_punkte_label.text = "Player: " + str(player.punkte)
		print("Computer Buchstaben: ", computer.get_buchstaben())
		
		
	else: # computer WAR an der reihe, wechsel zu player
		computer.ziehe_steine()
		
		an_der_reihe = player
		zug_beenden_button.disabled = false
		#animation_player.stop("computer_denkt")
		#animation_player.play("RESET")
		if not last_round:
			zug_beenden_button_label.text = "Passen"
		else:
			zug_beenden_button_label.text = "Spielende"
		computerdenkt_fortschrittanzeige.visible = false
		
		computerzug.aktiv = false
		var allowed_felder = get_allowed_spielfelder()
		set_allowed_spielfelder(allowed_felder)
		#computer_punkte_label.text = "Computer: " + str(computer.punkte)
		spielfeld_is_locked = false
		
func change_zug_beenden_label(frisch_belegt):
	if player.get_markierte_steine():
	
		zug_beenden_button_label.text = "Steine tauschen"
	elif not frisch_belegt:
		if not last_round:
			zug_beenden_button_label.text = "Passen"
		else:
			zug_beenden_button_label.text = "Spielende"
	else:
		zug_beenden_button_label.text = "Wort legen"
	

func mouse_pos_to_spielfeld_pos(mouse_pos):
	
	var relative_mouse_pos = (mouse_pos - offset_screen_mitte)  / camera.zoom
	return relative_mouse_pos + camera.position 

func spielfeld_pos_to_mouse_pos(spielfeld_pos):
	var relative_mouse_pos = spielfeld_pos - camera.position
	return (relative_mouse_pos * camera.zoom) + offset_screen_mitte
	
	
func regex_operation(pattern):
	#pattern = "\\n" + pattern + "\\n" # falsch! findet sonst viel zu wenig!!!
	#print("starte regex mit ", pattern)
	var regex = RegEx.new()
	if regex.compile(pattern) == OK:
		var matches_raw = regex.search_all(wortliste_txt)
		#print(len(matches_raw), " gefunden")
		var new_matches_dict = {}
		for single_match in matches_raw:
			var single_match_txt = single_match.get_string()
			single_match_txt = single_match_txt.strip_edges()
			#print(single_match_txt)
			#if not single_match_txt in new_matches_txt:
			new_matches_dict[single_match_txt] = true
				
		#print("regex ende")
		var filtered_woerter = filter_in_wortliste(new_matches_dict.keys())
		return filtered_woerter
	else:
		print("regex fehler!!!")

func open_popup(button_txt_lst, art, info):
	button_txt_lst.sort()
	popup_menu.visible = true
	
	spielfeld_is_locked = true
	zug_beenden_button.disabled = true
	zug_beenden_button.label.visible = false
		
	for but_txt in button_txt_lst:
		var new_button = button_scene.instantiate()
		
		popup_menu.container.add_child(new_button)
		new_button.label.text = but_txt
		new_button.art = art
		var button_info = {}
		if art == "Fragezeichen ersetzen":
			var wort_dict = info
			
			#var first_zelle = info[0]
			#var second_zelle = info[1]
			#var richtung = Vector2(info[1]) - Vector2(info[0])
			var stelle = 0
			for zelle in wort_dict:
				if wort_dict[zelle] == "?":
					button_info[zelle] = but_txt[stelle]
				stelle += 1
		new_button.info = button_info
		#print(new_button.size)

func close_popup(button_txt, art, ersetzen_dict):
	
	var children = popup_menu.container.get_children()
	for child in children:
		child.queue_free()
	
	popup_menu.visible = false
	
	spielfeld_is_locked = false
	zug_beenden_button.disabled = false
	zug_beenden_button.label.visible = true
	
	
	#print(button_txt, " picked")
	
	if art == "Fragezeichen ersetzen":
		assert (ersetzen_dict)
		var spielsteine_to_reverse_dict = {}
		for zelle in ersetzen_dict:
			print(all_spielfelder[zelle])
			print(all_spielfelder[zelle].spielstein_auf_feld)
			all_spielfelder[zelle].spielstein_auf_feld.label_buchstabe.text = ersetzen_dict[zelle]
			all_spielfelder[zelle].frisch_belegt = true
			spielsteine_to_reverse_dict[all_spielfelder[zelle].spielstein_auf_feld] = zelle
		player_zug_beenden(spielsteine_to_reverse_dict)   # info wenn wegen zweitwort nicht möglich ...!
		spielfeld_is_locked = false
	

func filter_in_wortliste(matches_lst):
	#print(len(matches_lst), " vorher")
	var filtered_woerter = []
	# debug
	for new_match_txt in matches_lst:
		if new_match_txt in wortliste_dict:
			filtered_woerter.append(new_match_txt)
	#print(len(filtered_woerter), " nachher")
	return filtered_woerter
		
