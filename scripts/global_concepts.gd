extends Node



@onready var spielbrett = $"/root/Main/Spielbrett"
@onready var spielbereich_spielfelder = $"/root/Main/Spielbrett/Spielfelder"
@onready var spielbereich_abgelegte_steine = $"/root/Main/Spielbrett/AbgelegteSteine"
@onready var player = $"/root/Main/Player"
@onready var computer = $"/root/Main/Computer"
@onready var player_punkte_label = $"/root/Main/UICanvasLayer/LabelPlayer"
@onready var computer_punkte_label = $"/root/Main/UICanvasLayer/LabelComputer"

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

var punkte_tweens = {}

var brett_ist_leer 
var dragged_stein = null
var spielstein_is_dragged = false
var snap_field = null
var all_spielfelder = {}
#var allowed_richtungen = [[-1, 0], [1, 0], [0, -1], [0, 1]]

var wortliste_txt = load_wortliste_txt()
var wortliste_dict = get_wortliste_dict(wortliste_txt)
#var wortliste_txt = wortliste_lst_and_txt[1]



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

func load_wortliste_txt():
	var wortliste_file = FileAccess.open("res://wortliste.txt", FileAccess.READ)
	var wortliste_text = wortliste_file.get_as_text()
	return wortliste_text

func get_wortliste_dict(wortliste_text):
	var wortliste_list = wortliste_text.split("\n")
	var wortliste_dict = {}
	
	for wort in wortliste_list:
		wort = wort.strip_edges()
		if wort:
			wortliste_dict[wort] = true
	#print(len(wortliste_dict))
	return wortliste_dict
	
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

func read_gelegte_woerter():
	
	var belegte_felder = get_belegte_felder(false)
	var frisch_gelegte_felder = get_belegte_felder(true)
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
						alle_woerter.append([new_word, buchstaben_dict, true])
					else:
						alle_woerter.append([new_word, buchstaben_dict, false])
				stelle_variabel += 1
	
	return alle_woerter
	
	#
func get_allowed_spielfelder():
	# TODO: erlauben, buchstaben zu legen, aber markieren, wenn nicht in allowed
	
	
	
	var belegte_felder = get_belegte_felder(false)
	var frisch_belegte_felder = get_belegte_felder(true)
	change_zug_beenden_label(frisch_belegte_felder, [])
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
			var test_feld = [checkfeld[0] + richtung[0], checkfeld[1] + richtung[1]]
			if test_feld in belegte_felder:
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
	var frisch_belegte_felder = get_belegte_felder(true)
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
				var old_pos = spielstein_auf_feld.position - spielstein_auf_feld.offset_hand - camera.position
				
				spielstein_auf_feld.return_to_hand(old_pos)
				spielfeld.spielstein_auf_feld = null
				
				
		#GlobalConcepts.all_spielfelder[feld].frisch_belegt = false
		
	#print("nicht mehr frisch")
	
	
func player_zug_beenden():
	#print("player zug beenden")
	var player_zug_erlaubt = true
	
	
	var frisch_gelegt = get_belegte_felder(true)
	var allowed_felder = get_allowed_spielfelder()
	var gelegte_woerter = read_gelegte_woerter()
	
	if zug_beenden_button_label.text == "Steine tauschen":
		assert(not frisch_gelegt)
		player.steine_tauschen()
	else:
		player_zug_erlaubt = is_player_zug_gueltig(allowed_felder, gelegte_woerter)
				
	update_spielbrett(player_zug_erlaubt)
	
	if player_zug_erlaubt:
		player.punkte += get_punkte_player(gelegte_woerter, frisch_gelegt)
		
		change_an_der_reihe()
	else:
		allowed_felder = get_allowed_spielfelder()
		set_allowed_spielfelder(allowed_felder)
		

func get_punkte_player(gelegte_woerter, frisch_gelegte_felder):
	var neue_woerter = []
	# gd script kennt wohl keine list comprehension!
	
	var punkte_fuer_bereits_gelegte_felder = 0
	for wort_lst in gelegte_woerter:
		var is_new = wort_lst[2]
		if is_new:
			neue_woerter.append(wort_lst)
			# abrechnung für bereits gelegte felder
			var buchstaben_dict = wort_lst[1]
			for feld in buchstaben_dict:
				if not feld in frisch_gelegte_felder:
					var buchstabe = buchstaben_dict[feld]
					punkte_fuer_bereits_gelegte_felder += GlobalGameSettings.spielsteine_start[buchstabe]["Wert"]
	
	#var neue_woerter_sort
	
	if len(neue_woerter) > 1:
		var punkte = []
		for wort in neue_woerter:
			var ergebnis = get_punkte_wort(wort, [], frisch_gelegte_felder, false)
			punkte.append(ergebnis[1])
		
		if punkte[1] > punkte[0]:
			neue_woerter.reverse()
		
	
	var punkte = 0
	for wort in neue_woerter:
		var bereits_abgerechnet = []
		var ergebnis = get_punkte_wort(wort, bereits_abgerechnet, frisch_gelegte_felder, true)
		bereits_abgerechnet = ergebnis[0]
		punkte += ergebnis[1]
	print("Player erhält ", punkte + punkte_fuer_bereits_gelegte_felder, " Punkte")
	return punkte + punkte_fuer_bereits_gelegte_felder
	
func get_punkte_wort(wort_lst, bereits_abgerechnet, frisch_gelegte_felder, show_on_screen):
	var wort_wert_bonus_faktor = 1
	var buchstaben_wert_bonus_faktor = 1
	var punkte = 0
	var buchstaben_dict = wort_lst[1]
	var alle_buchstaben_bonus = 0
	if len(frisch_gelegte_felder) == GlobalGameSettings.anzahl_steine_pro_hand:
		alle_buchstaben_bonus = 50
		
	for feld in buchstaben_dict:
		var buchstabe = buchstaben_dict[feld]
		if feld in frisch_gelegte_felder and not feld in bereits_abgerechnet:
			if feld in GlobalGameSettings.spezialfelder["dreifacher Wortwert"]:
				wort_wert_bonus_faktor = 3
			elif feld in GlobalGameSettings.spezialfelder["doppelter Wortwert"]:
				wort_wert_bonus_faktor = 2
			if feld in GlobalGameSettings.spezialfelder["dreifacher Buchstabenwert"]:
				buchstaben_wert_bonus_faktor = 3
			elif feld in GlobalGameSettings.spezialfelder["doppelter Wortwert"]:
				buchstaben_wert_bonus_faktor = 2
			
			var new_punkte = GlobalGameSettings.spielsteine_start[buchstabe]["Wert"] * buchstaben_wert_bonus_faktor
			
			
			punkte += new_punkte
			bereits_abgerechnet.append(feld)
	
	if show_on_screen:
		create_punkte_label(frisch_gelegte_felder[0], punkte)
	punkte *= wort_wert_bonus_faktor + alle_buchstaben_bonus
	return [bereits_abgerechnet, punkte]
		
	
	
func create_punkte_label(feld, punkte):
	
	var punkte_label_auf_stein = all_spielfelder[feld].punkte_label
	var punkte_label_auf_stein_timer = all_spielfelder[feld].punkte_label_timer
	punkte_label_auf_stein.visible = true
	punkte_label_auf_stein.text = str(punkte)
	var tween = create_tween()
	punkte_tweens[feld] = tween
	var max_size = 1 + punkte/4
	var dauer = 1.5
	tween.tween_property(punkte_label_auf_stein, "scale", Vector2(max_size, max_size), dauer)
	tween.parallel().tween_property(punkte_label_auf_stein, "modulate:a", 0, dauer)
	punkte_label_auf_stein_timer.wait_time = dauer
	punkte_label_auf_stein_timer.start()
	
	

func is_player_zug_gueltig(allowed_felder, gelegte_woerter):
	
	if not allowed_felder:  # zug ungültig!
		print("zug ungültig! falsch gelegt")
		return false
		
	for wort_lst in gelegte_woerter:
		var wort = wort_lst[0]
		
		if wort.strip_edges() not in wortliste_dict:
			print(wort, " nicht in liste (weitere wurden nicht geprüft)")
			return false
		else:
			print(wort, " in liste")
	return true
	
		
		
func change_an_der_reihe():
	if an_der_reihe == player:  # player WAR an der reihe, wechsel zu computer
		player.ziehe_steine()
		
		an_der_reihe = computer
		zug_beenden_button.disabled = true
		zug_beenden_button_label.text = "Computer denkt ..."
		
		animation_player.play("computer_denkt")
		computerzug.restart()
		#computerzug.init_word_array()
		player_punkte_label.text = "Player: " + str(player.punkte)
	else: # computer WAR an der reihe, wechsel zu player
		computer.ziehe_steine()
		
		an_der_reihe = player
		zug_beenden_button.disabled = false
		#animation_player.stop("computer_denkt")
		animation_player.play("RESET")
		zug_beenden_button_label.text = "Passen"
		
		computerdenkt_fortschrittanzeige.visible = false
		
		computerzug.aktiv = false
		var allowed_felder = get_allowed_spielfelder()
		set_allowed_spielfelder(allowed_felder)
		computer_punkte_label.text = "Computer: " + str(computer.punkte)

func change_zug_beenden_label(frisch_belegt, player_steine_dict):
	if player.get_markierte_steine():
	
		zug_beenden_button_label.text = "Steine tauschen"
	elif not frisch_belegt:
		zug_beenden_button_label.text = "Passen"
	else:
		zug_beenden_button_label.text = "Wort legen"
	
