extends Node

var aktiv = false
var durchgang:float = 0.0
var max_durchgaenge = 0#GlobalGameSettings.computer_denktiefe
@onready var computerdenkt_fortschrittanzeige: ColorRect = $"/root/Main/UICanvasLayer/ZugBeenden/ComputerdenktFortschrittanzeige"
@onready var fortschrittanzeige_max_breite = computerdenkt_fortschrittanzeige.size.x
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"
var percent: float = 0.0
#var word_array
var moegliche_woerter = []
var zu_pruefende_reihen = []
var zu_pruefende_spalten = []
var computer_buchstaben = []
var belegte_felder = []
var word_array_waagrecht = []
var word_array_senkrecht = []

func _ready() -> void:
	computerdenkt_fortschrittanzeige.visible = false

func restart():
	moegliche_woerter = []
	computerdenkt_fortschrittanzeige.visible = true
	aktiv = true
	durchgang = 0
	
	zu_pruefende_reihen = []
	zu_pruefende_spalten = []
	
	var belegte_felder = global_concepts.get_belegte_felder(false)
	
	
	
	for all_feld in belegte_felder:
		if all_feld[0] not in belegte_felder and all_feld[0] not in zu_pruefende_spalten:
			zu_pruefende_spalten.append(all_feld[0])
		if all_feld[1] not in belegte_felder and all_feld[1] not in zu_pruefende_reihen:
			zu_pruefende_reihen.append(all_feld[1])
	
	if not belegte_felder:  # neues spiel
		zu_pruefende_reihen = [7]
	
	max_durchgaenge = len(zu_pruefende_reihen) + len(zu_pruefende_spalten)
	computer_buchstaben = global_concepts.computer.get_buchstaben()
	computer_buchstaben.sort()
	belegte_felder = global_concepts.get_belegte_felder(false)
	
	var word_array_lst = get_word_array(belegte_felder)
	word_array_waagrecht = word_array_lst[0]
	word_array_senkrecht = word_array_lst[1]
	
	
func draw_bar():
	var new_breite = fortschrittanzeige_max_breite * percent
		
	computerdenkt_fortschrittanzeige.size.x = new_breite
	computerdenkt_fortschrittanzeige.color.r = 1- percent
	computerdenkt_fortschrittanzeige.color.g = percent

func get_word_array(belegte_felder):
	# waagrecht
	var array_waagrecht = []
	
	for y in range(GlobalGameSettings.anzahl_felder):
		var new_zeile = ""
		for x in range(GlobalGameSettings.anzahl_felder):
			
			var buchstabe = belegte_felder.get([x,y])
			if not buchstabe:
				new_zeile += " "
			else:
				new_zeile += buchstabe
		array_waagrecht.append(new_zeile)
	# vertikal
	var array_vertikal = []
	for x in range(GlobalGameSettings.anzahl_felder):
		var new_zeile = ""
		for y in range(GlobalGameSettings.anzahl_felder):
			
			var buchstabe = belegte_felder.get([x,y])
			if not buchstabe:
				new_zeile += " "
			else:
				new_zeile += buchstabe
		array_vertikal.append(new_zeile)
	
	return [array_waagrecht, array_vertikal]
	
			
	
	
func think_durchgang(zu_pruefende_reihe_oder_spalte_nr, info_reihe_oder_spalte_txt, belegte_felder):
	var zu_pruefende_reihe_oder_spalte_txt = ""
	if info_reihe_oder_spalte_txt == "reihe":
		zu_pruefende_reihe_oder_spalte_txt = word_array_waagrecht[zu_pruefende_reihe_oder_spalte_nr]
	elif info_reihe_oder_spalte_txt == "spalte":
		zu_pruefende_reihe_oder_spalte_txt = word_array_senkrecht[zu_pruefende_reihe_oder_spalte_nr]
	
	
	
	var all_lst = get_words_and_zellen_from_string_and_pattern(zu_pruefende_reihe_oder_spalte_txt, zu_pruefende_reihe_oder_spalte_nr, info_reihe_oder_spalte_txt)
	var buchstaben_dict = all_lst[0]
	var pattern = all_lst[1]
	
	#if not belegte_felder:
		#moegliche_woerter += global_concepts.wortliste_dict.keys()
	
	moegliche_woerter += find_moegliche_woerter(pattern, computer_buchstaben, buchstaben_dict, info_reihe_oder_spalte_txt, zu_pruefende_reihe_oder_spalte_nr, belegte_felder)

	
func get_words_and_zellen_from_string_and_pattern(text, reihe_oder_spalte_nr, waag_oder_senkrecht):
	var buchstaben_dict = {}
	var pattern = ""
	
	var stelle = 0
	var leerzeichen = 0
	#var aufzeichnung = false
	#var new_wort_dict = {}
	var wortbeginn_stelle = null
	#var zelle
	var new_wort = ""
	#var new_wort_beginn_stelle = null
	while true:
		
		var buchstabe = text[stelle]
		if buchstabe == " ":
			if new_wort: # wort zu ende
				
				buchstaben_dict[new_wort] = wortbeginn_stelle
				new_wort = ""
				wortbeginn_stelle = null
				#new_wort_dict = {}
			leerzeichen += 1
		else:
			if not new_wort:  # aufzeichnung beginnt
				pattern += ".{0," + str(leerzeichen) +  "}"
				leerzeichen = 0
				wortbeginn_stelle = stelle
			pattern += buchstabe
			
			#new_wort_dict[zelle] = buchstabe
			new_wort += buchstabe
			
			
				
		stelle += 1
		if stelle >= len(text):
			
			break
		
	pattern += ".{0," + str(leerzeichen) +  "}\n"
	
	#print(waag_oder_senkrecht, " ", reihe_oder_spalte_nr)
	#print(buchstaben_dict)
	#print(pattern)
	return [buchstaben_dict, pattern]

func find_moegliche_woerter(pattern, computer_buchstaben, woerter_dict, info_waag_oder_senkrecht, reihe_oder_spalte_nr, belegte_felder):
	
	
	#var woerter_in_reihe_oder_spalte = get_words_and_zellen_from_string(zu_pruefende_reihe_oder_spalte_txt)
	
	var moegliche_woerter = []
	#print("buchstaben: ", computer_buchstaben)
	var regex = RegEx.new()
	if regex.compile(pattern) == OK:
		var matches = regex.search_all(global_concepts.wortliste_txt)
		if not matches:
			#print("Keine Matches gefunden!")
			return []
		
		for single_match in matches:
			var single_match_txt = single_match.get_string()
			single_match_txt = single_match_txt.strip_edges()
			
			var wortbeginn_wort
			#var position = single_match.get_start()
			#print("Gefunden: ", single_match_txt)
			var gelegtes_wort = null
			if not woerter_dict: # neues spiel - leeres brett, computer legt nur waagrecht
				var fehlende_buchstaben = single_match_txt.split()
				if not hat_alle_buchstaben(fehlende_buchstaben, computer_buchstaben):
					continue
				var lege_dict = get_lege_dict_for_new_game(single_match_txt, "reihe")
				var richtung = [1,0]
				
				moegliche_woerter.append([single_match_txt, lege_dict, richtung])
				continue
			
			for wort in woerter_dict:
				var stelle_in_woerterbuch_wort = single_match_txt.find(wort)
				if stelle_in_woerterbuch_wort != -1:
					gelegtes_wort = wort
					wortbeginn_wort = woerter_dict[gelegtes_wort] - stelle_in_woerterbuch_wort
					#break
				if not gelegtes_wort:
					continue
				var zelle_beginn
				var richtung 
				if info_waag_oder_senkrecht == "reihe":
					zelle_beginn = [wortbeginn_wort, reihe_oder_spalte_nr]
					richtung = [1, 0]
				else:
					zelle_beginn = [reihe_oder_spalte_nr, wortbeginn_wort]
					richtung = [0, 1]
				#print(single_match_txt, " beginn: ", zelle_beginn)
				var lege_dict = get_lege_dict(single_match_txt, zelle_beginn, richtung)	
				
				if lege_dict:
					#print("möglich: ", single_match_txt)
					moegliche_woerter.append([single_match_txt, lege_dict, richtung])
				#else:
					#print(single_match_txt, " nicht möglich!")
			
					
	return moegliche_woerter

func get_lege_dict_for_new_game(single_match_txt, info_waagrecht_oder_senkrecht):
	
	var richtung = 1
	
	var alle_buchstabenwerte_lst = []
	
	var stelle = 0
	for buchstabe in single_match_txt:
		var wert = GlobalGameSettings.spielsteine_start[buchstabe]["Wert"]
		alle_buchstabenwerte_lst.append([wert, stelle])
		stelle += 1
	alle_buchstabenwerte_lst.sort()
	alle_buchstabenwerte_lst.reverse()
	
	var platz_vorn
	var platz_hinten
	var lege_dict = {}
	var first_zelle = null
	if len(single_match_txt) <= 4:
		first_zelle = [7,7]
	
	
	
	
	for info in alle_buchstabenwerte_lst:
		if first_zelle:
			break
		
		for test_zelle in [[3,7], [11,7]]:
			platz_vorn = info[1]
			platz_hinten = len(single_match_txt) - (platz_vorn + 1)
			if test_zelle == [3,7]:
				if platz_hinten < 4:
					continue
				else:
					first_zelle = [3-platz_vorn, 7]
					break
			if test_zelle == [11,7]:
				if  platz_vorn < 4:
					continue
				else:
					first_zelle = [11-platz_vorn, 7]
					break
	var zelle = first_zelle
	for buchstabe in single_match_txt:
	
		lege_dict[zelle] = buchstabe
		zelle = [zelle[0] + richtung, zelle[1]]
	return lege_dict
		
		
		
		
		
		#var wert = info[0]
		#
		#if platz_vorn < 4 and platz_hinten < 4:  # geht sich weder vorn noch hinten aus
			#first_zelle = [7,7]
			#
		#elif platz_vorn >= 4:
			#first_zelle = [7 - richtung * platz_hinten, 7]
		#elif platz_hinten >= 4:
			#first_zelle = [7 - richtung * platz_hinten, 7]
		#else:
			#push_error("Fehler!")
		#if not first_zelle == [7,7]:
			#print(single_match_txt, " first zelle: ", first_zelle)
		#var zelle = first_zelle
		#for buchstabe in single_match_txt:
			#
			#lege_dict[zelle] = buchstabe
			#zelle = [zelle[0] + richtung, zelle[1]]
		#return lege_dict
	# TODO!!!!!
	#while not wortbeginn:
#		var best_ix = alle_buchstabenwerte.index(max(alle_buchstabenwerte))
	
	#if len(single_match_txt) < 4:
		#wortbeginn = [7,7]
	#
	#
	#for buchstabe in single_match_txt:
		#pass
	#
	
	for spezial in GlobalGameSettings.spezialfelder:
		pass

func get_lege_dict(single_match_txt, zelle_beginn, richtung):
	#print("checking ", single_match_txt, " länge: ", len(single_match_txt))
	var zelle = zelle_beginn
	var lege_dict = {}
	#var buchstabe
	var fehlende_buchstaben = []
	var abstand = 0
	for buchstabe in single_match_txt:
		
		zelle = [zelle_beginn[0] + richtung[0] * abstand, zelle_beginn[1] + richtung[1] * abstand]
		#buchstabe = single_match_txt[stelle]
		if zelle not in belegte_felder:  # muss gelegt werden
			lege_dict[zelle] = buchstabe
			if not buchstabe in computer_buchstaben:
				#if len(single_match_txt) < 5:
					#print(buchstabe, " in ", single_match_txt, " fehlt", " buchstaben: ", computer_buchstaben)
				return false
			fehlende_buchstaben.append(buchstabe)
		abstand += 1
	if not fehlende_buchstaben:  # ist ident mit bereits gelegtem
		return false 
	if not hat_alle_buchstaben(fehlende_buchstaben, computer_buchstaben):
		return false

	return lege_dict

func sort_by_punkte(woerter):
	woerter.sort_custom(func(a, b): return a[1] > b[1])
	return woerter

func test_moegliches_wort_auf_querschlaeger_und_get_punkte(wort_dict, belegte_felder, check_querwoerter):
	"""
	hier wird geprüft, ob die wörter tatsächlich so gelegt werden können
	ist seitlich bzw. ober-unterhalb des probeweise gelegten buchstabens ein bereits gelegter buchstabe? 
	dann schauen, ob gültiges wort
	die legerichtung ist bereits überprüft! es geht nur um "querschläger"
	außerdem werden die punkte ermittelt
	"""
	var moegliche_punkte = 0
	var wort_wert_bonus_faktor = 1 
	var wort = wort_dict[0]
	var zu_legende_buchstaben_dict = wort_dict[1]
	var richtung = wort_dict[2]
	
	var abrechnen_bereits_gelegtes_wort = wort
	var alle_buchstaben_gelegt_bonus 
	if len(zu_legende_buchstaben_dict) == GlobalGameSettings.anzahl_steine_pro_hand:
		alle_buchstaben_gelegt_bonus = 50
	else:
		alle_buchstaben_gelegt_bonus = 0
			
	for feld in zu_legende_buchstaben_dict:
		var buchstaben_wert_bonus_faktor = 1
		var buchstabe = zu_legende_buchstaben_dict[feld]
		if check_querwoerter:
			var querrichtung = [richtung[1], richtung[0]]
			var querwort_pruefung_ergebnis = check_querwort_okay(feld, querrichtung, buchstabe, belegte_felder)
			var ergebnis_okay = querwort_pruefung_ergebnis[0]
			var zusatzpunkte = querwort_pruefung_ergebnis[1]
			
			if not ergebnis_okay:
				return [false, 0]
			else:
				moegliche_punkte += zusatzpunkte
				#print("zusatzpunkte querwort ", zusatzpunkte)
			
		if feld in GlobalGameSettings.spezialfelder["dreifacher Wortwert"]:
			wort_wert_bonus_faktor = 3
		elif feld in GlobalGameSettings.spezialfelder["doppelter Wortwert"]:
			wort_wert_bonus_faktor = 2
		if feld in GlobalGameSettings.spezialfelder["dreifacher Buchstabenwert"]:
			buchstaben_wert_bonus_faktor = 3
		elif feld in GlobalGameSettings.spezialfelder["doppelter Wortwert"]:
			buchstaben_wert_bonus_faktor = 2
		
		
		moegliche_punkte += GlobalGameSettings.spielsteine_start[buchstabe]["Wert"] * buchstaben_wert_bonus_faktor + alle_buchstaben_gelegt_bonus
		#print("punkte für ", buchstabe, " :", GlobalGameSettings.spielsteine_start[buchstabe]["Wert"] * buchstaben_wert_bonus_faktor)
		abrechnen_bereits_gelegtes_wort = replace_first_occurance(abrechnen_bereits_gelegtes_wort, buchstabe)	
	
	for abr_buchstabe in abrechnen_bereits_gelegtes_wort:
		moegliche_punkte += GlobalGameSettings.spielsteine_start[abr_buchstabe]["Wert"]
		#print("punkte für bereits gelegten buchstaben ", abr_buchstabe, " :", GlobalGameSettings.spielsteine_start[abr_buchstabe]["Wert"])
	moegliche_punkte *= wort_wert_bonus_faktor
		
	
	
	return [true, moegliche_punkte]

func replace_first_occurance(wort, buchstabe):
	var index = wort.find(buchstabe)
	if index != -1:
		return wort.substr(0, index) + "" + wort.substr(index + 1)
	return wort


func check_querwort_okay(feld, querrichtung, buchstabe, belegte_felder):
	
	var new_wort = buchstabe
	
	for vor_zurueck in [[querrichtung[0] * -1, querrichtung[1] * -1], [querrichtung[0], querrichtung[1]]]:
		
		var distance = 1
		while true:
			var checkfeld = [feld[0] + vor_zurueck[0] * distance, feld[1] + vor_zurueck[1] * distance]
			var new_buchstabe = belegte_felder.get(checkfeld)
			if not new_buchstabe:
				break
			if vor_zurueck[0] == -1 or vor_zurueck[1] == - 1:  # es geht rückwärts
				new_wort = new_buchstabe + new_wort
			else:
				new_wort += new_buchstabe
			distance += 1
			
	if len(new_wort) <= 1 or new_wort in global_concepts.wortliste_lst:
		# wort kann geschrieben werden
		var zusatzpunkte = 0
		
		if len(new_wort) > 1:
			for abr_buchst in new_wort:
				zusatzpunkte += GlobalGameSettings.spielsteine_start[abr_buchst]["Wert"]	
		
		return [true, zusatzpunkte]
	else:
		# wort kann nicht geschrieben werden
		return [false, 0]


func hat_alle_buchstaben(fehlende_buchstaben, computer_buchstaben):
	fehlende_buchstaben.sort()
	for buchst in fehlende_buchstaben:
		if buchst not in computer_buchstaben:
			#print("... kann nicht geschrieben werden, fehlendes ", buchst)
			return false
		if fehlende_buchstaben.count(buchst) > computer_buchstaben.count(buchst):
			#print("... kann nicht geschrieben werden, nicht genug ", buchst)
			return false  # nicht dieselbe anzahl vorhanden
	#print(" ... kann geschrieben werden")
	return true



func _process(delta: float) -> void:
	# todo: was tun, wenn kein wort geschrieben ist?
	# todo: was tun, wenn kein wort geschrieben werden kann? -> buchstaben tauschen!
	if aktiv:
		#print("aktiv", aktiv)
			
		durchgang += 1
		percent = durchgang/max_durchgaenge
		draw_bar()
		if zu_pruefende_reihen:
			var zu_pruefende_reihe = zu_pruefende_reihen.pop_front()
			think_durchgang(zu_pruefende_reihe, "reihe", belegte_felder)
		elif zu_pruefende_spalten:
			var zu_pruefende_spalte = zu_pruefende_spalten.pop_front()
			think_durchgang(zu_pruefende_spalte, "spalte", belegte_felder)
		#print("bisher ", len(moegliche_woerter), " gefunden")
		if durchgang >= max_durchgaenge:
			#print("ende computerzug")
			if not belegte_felder:
				thinking_ende(false)
			else:
				thinking_ende(true)
			

func thinking_ende(brett_ist_nicht_leer):
	var erlaubte_woerter = []
	for pruefwort in moegliche_woerter:
		#print("prüfe ", pruefwort, " aus moeglichen wortern auf querwortprobleme")
		if not pruefwort in global_concepts.wortliste_dict:
			
			push_error("Fehler!! Wort ", pruefwort, " nicht in Wortliste!")
		var ergebnis_test = test_moegliches_wort_auf_querschlaeger_und_get_punkte(pruefwort, belegte_felder, brett_ist_nicht_leer)
		var allowed = ergebnis_test[0]
		
		var punkte = ergebnis_test[1] 
		if allowed:
			erlaubte_woerter.append([pruefwort, punkte])
			#print("erlaubt: ", [pruefwort, punkte])
		#else:
			#print("nicht erlaubt: ", [pruefwort, punkte])
	
	var sort_erlaubte_woerter = sort_by_punkte(erlaubte_woerter)
	# TODO: WAS wenn keines legbar? -> computer tauscht steine oder passt
	#print("bestes wort ", sort_erlaubte_woerter[0])
	
	#print("computer steine vor legen: ", computer_buchstaben)
	lege_steine(sort_erlaubte_woerter[0])
	
	#global_concepts.computer.ziehe_steine()
	aktiv = false
	global_concepts.change_an_der_reihe()
			
			

func lege_steine(wort_arr):
	
	var steine_pos_dict = wort_arr[0][1]
	#var computer_steine = global_concepts.computer.steine_dict
	var rel_stein_aus_hand = null
	
	for stein_pos in steine_pos_dict:
		# suchen des richtigen steins in der computerhand	
		var gesuchter_buchstabe = steine_pos_dict[stein_pos]
		
		for stein_nr in range(GlobalGameSettings.anzahl_steine_pro_hand):
			var test_stein = global_concepts.computer.steine_dict[stein_nr]
			if not test_stein: # schon ausgespielt
				continue
			if test_stein.label_buchstabe.text == gesuchter_buchstabe:
				global_concepts.computer.steine_dict[stein_nr] = null
				rel_stein_aus_hand = test_stein
				break
		if not rel_stein_aus_hand:
			push_error("Buchstabe fehlt!!!!! ", steine_pos_dict[stein_pos])
			
		
		
		global_concepts.computer.remove_child(rel_stein_aus_hand)
		global_concepts.spielbereich_abgelegte_steine.add_child(rel_stein_aus_hand)
		#test_stein.position = event.position + offset_hand + global_concepts.camera.position
		
		
		rel_stein_aus_hand.position.y = -100
		rel_stein_aus_hand.visible = true
		
		var new_pos_x = global_concepts.all_spielfelder[stein_pos].position.x
		var new_pos_y = global_concepts.all_spielfelder[stein_pos].position.y
		var tween = create_tween()
		tween.tween_property(rel_stein_aus_hand, "position", Vector2(new_pos_x, new_pos_y), 0.5)
		
		rel_stein_aus_hand.fixiert = true
		global_concepts.all_spielfelder[stein_pos].spielstein_auf_feld = rel_stein_aus_hand
		rel_stein_aus_hand.frisch_gelegt_sprite.visible = false
		rel_stein_aus_hand.fixiert_sprite.visible = true
		
