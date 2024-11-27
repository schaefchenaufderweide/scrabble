extends Node

var aktiv = false
var durchgang:float = 0.0
var max_durchgaenge = GlobalGameSettings.computer_denktiefe
@onready var computerdenkt_fortschrittanzeige: ColorRect = $"/root/Main/UICanvasLayer/ZugBeenden/ComputerdenktFortschrittanzeige"
@onready var fortschrittanzeige_max_breite = computerdenkt_fortschrittanzeige.size.x
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"
var percent: float = 0.0
#var word_array


func _ready() -> void:
	computerdenkt_fortschrittanzeige.visible = false
	

func draw_bar():
	var new_breite = fortschrittanzeige_max_breite * percent
		
	computerdenkt_fortschrittanzeige.size.x = new_breite
	computerdenkt_fortschrittanzeige.color.r = 1- percent
	computerdenkt_fortschrittanzeige.color.g = percent


func get_buchstaben():
	var buchstaben = []
	for stein_nr in global_concepts.computer.steine:
		buchstaben.append(global_concepts.computer.steine[stein_nr])
	return buchstaben
	
func think():
	var computer_buchstaben = get_buchstaben()

	computer_buchstaben.sort()
	
	var gelegte_woerter_mit_zelle_und_richtung = global_concepts.read_gelegte_woerter(true)
	var belegte_felder = global_concepts.get_belegte_felder(false)
	var zu_pruefen
	
	var moegliche_woerter = []
	
	for wort_lst in gelegte_woerter_mit_zelle_und_richtung:
		zu_pruefen = [wort_lst]
		
		var ausgangszelle = wort_lst[1]
		var zellen_add = 0
		# von einzelbuchstaben ausgehend
		for buchstab in wort_lst[0]:
			var neu_richtung 
			var neue_zelle
			if wort_lst[2] == "horizontal":
				neu_richtung = "vertikal"
				neue_zelle = [ausgangszelle[0], ausgangszelle[1] + zellen_add]
			else:
				neu_richtung = "horizontal"
				neue_zelle = [ausgangszelle[0] + zellen_add, ausgangszelle[1]]
			var neu_pruef = [buchstab, neue_zelle, neu_richtung]
			zu_pruefen.append(neu_pruef)
			zellen_add += 1
		
	for wort_lst in zu_pruefen:
		
		var wort = wort_lst[0]
		var zelle_beginn = wort_lst[1]
		var richtung
		if wort_lst[2] == "horizontal":
			richtung = [1, 0]
		else:
			richtung = [0, 1]
		
		moegliche_woerter += find_moegliche_woerter(wort, 0, computer_buchstaben, zelle_beginn, richtung, belegte_felder)
	
	var erlaubte_woerter = []
	for wort in moegliche_woerter:
		#print("prüfe ", wort)
		var ergebnis_test = test_moegliches_wort(wort, belegte_felder)
		var allowed = ergebnis_test[0]
		
		var punkte = ergebnis_test[1] 
		if allowed:
			erlaubte_woerter.append([wort, punkte])
			#print("erlaubt: ", [wort, punkte])
		#else:
			#print("nicht erlaubt: ", [wort, punkte])
	
	var sort_erlaubte_woerter = sort_by_punkte(erlaubte_woerter)
	for wort in sort_erlaubte_woerter:
		print(wort)
	
	# TODO: computer buchstaben legen!


func sort_by_punkte(woerter):
	woerter.sort_custom(func(a, b): return a[1] > b[1])
	return woerter

func test_moegliches_wort(wort_dict, belegte_felder):
	"""
	hier wird geprüft, ob die wörter tatsächlich so gelegt werden können
	ist seitlich bzw. ober-unterhalb des probeweise gelegten buchstabens ein bereits gelegter buchstabe? 
	dann schauen, ob gültiges wort
	die legerichtung ist bereits überprüft! es geht nur um "querschläger"
	"""
	var moegliche_punkte = 0
	var wort_wert_bonus_faktor = 1 
	var wort = wort_dict[0]
	var zu_legende_buchstaben_dict = wort_dict[1]
	var richtung = wort_dict[2]
	
	var abrechnen_bereits_gelegtes_wort = wort
	
	for feld in zu_legende_buchstaben_dict:
		var buchstaben_wert_bonus_faktor = 1
		var buchstabe = zu_legende_buchstaben_dict[feld]
		
		var querrichtung = [richtung[1], richtung[0]]
		var querwort_pruefung_ergebnis = check_querwort_okay(feld, querrichtung, buchstabe, belegte_felder)
		var ergebnis_okay = querwort_pruefung_ergebnis[0]
		var zusatzpunkte = querwort_pruefung_ergebnis[1]
		
		if not ergebnis_okay:
			return [false, 0]
		else:
			moegliche_punkte += zusatzpunkte
			#print("zusatzpunkte querwort ", zusatzpunkte)
		#print("dreifacher Wortwert: ", feld in GlobalGameSettings.spezialfelder["dreifacher Wortwert"])
		#print("doppelter Wortwert: ", feld in GlobalGameSettings.spezialfelder["doppelter Wortwert"])
		#print("dreifacher Buchstabenwert: ", feld in GlobalGameSettings.spezialfelder["dreifacher Buchstabenwert"])
		#print("doppelter Wortwert: ", feld in GlobalGameSettings.spezialfelder["doppelter Wortwert"])
		
		if feld in GlobalGameSettings.spezialfelder["dreifacher Wortwert"]:
			wort_wert_bonus_faktor = 3
		elif feld in GlobalGameSettings.spezialfelder["doppelter Wortwert"]:
			wort_wert_bonus_faktor = 2
		if feld in GlobalGameSettings.spezialfelder["dreifacher Buchstabenwert"]:
			buchstaben_wert_bonus_faktor = 3
		elif feld in GlobalGameSettings.spezialfelder["doppelter Wortwert"]:
			buchstaben_wert_bonus_faktor = 2
		
		
		moegliche_punkte += GlobalGameSettings.spielsteine_start[buchstabe]["Wert"] * buchstaben_wert_bonus_faktor
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
		
		
		var checkfeld = [feld[0] + vor_zurueck[0], feld[1] + vor_zurueck[1]]
		
		
		
		var new_buchstabe = belegte_felder.get(checkfeld)
		while new_buchstabe:
		
			if vor_zurueck[0] == -1 or vor_zurueck[1] == - 1:  # es geht rückwärts
				new_wort = new_buchstabe + new_wort
			else:
				new_wort += new_buchstabe
	if not new_wort or new_wort in global_concepts.wortliste_txt:
		# wort kann geschrieben werden
		var zusatzpunkte = 0
		
		if len(new_wort) > 1:
			for abr_buchst in new_wort:
				zusatzpunkte += GlobalGameSettings.spielsteine_start[abr_buchst]["Wert"]	
		
		return [true, zusatzpunkte]
	else:
		# wort kann nicht geschrieben werden
		return [false, 0]

func is_a_letter(letter):
	
	var allowed = letter in GlobalGameSettings.allowed_letters # (letter.unicode_at(0) >= 65 and letter.unicode_at(0) <= 90) or letter in ["Ä", "Ö", "Ü"]
	return allowed

func find_moegliche_woerter(wort, suche_start_x, debug_computer_buchstaben, wortbeginn_zelle, wortrichtung, belegte_felder):
	"""
	dies überprüft allein die möglichkeit, die aufgrund der buchstaben und der wortliste gegeben sind.
	"""
	var moegliche_woerter = []
	
	var find_x = global_concepts.wortliste_txt.find(wort, suche_start_x)
	
	while find_x != -1:
		#print("Fortschritt: ", find_x, "/", len(global_concepts.wortliste_txt))
		var abbruch = false
		var fehlende_buchstaben = []
		var check_x = find_x - 1
		var letter = global_concepts.wortliste_txt[check_x]
		
		var wortbeginn_x 
		#var abstand_letter = check_x - find_x
		var suchrichtung = - 1
		var zelle 
		var lege_dict = {}
			
		while not abbruch:
			while is_a_letter(letter):
				var abstand_letter = check_x - find_x
				zelle = [wortbeginn_zelle[0] + wortrichtung[0] * abstand_letter, wortbeginn_zelle[1] + wortrichtung[1] * abstand_letter]
				
				if zelle[0] < 0 or zelle[1] < 0 or zelle[0] > GlobalGameSettings.anzahl_felder or zelle[1] > GlobalGameSettings.anzahl_felder:
					#print(zelle, " außerhalb!")
					abbruch = true
					break
				if not zelle in belegte_felder:
					fehlende_buchstaben.append(letter)
					lege_dict[zelle] = letter
					
					if not letter in debug_computer_buchstaben:
						#print(letter, " fehlt")
						abbruch = true
						break
				
				check_x += suchrichtung
				letter = global_concepts.wortliste_txt[check_x]
				#abstand_letter = check_x - find_x 
				
			if not wortbeginn_x:  # wortbeginn erzielt
				#print("wortbeginn erreicht")
				wortbeginn_x = check_x + 1
				check_x = find_x + 1
				letter = global_concepts.wortliste_txt[check_x]
				suchrichtung = 1
				#abstand_letter = check_x - find_x 
			else:
				break
		if not abbruch: # normales wortende erzielt
			#print("normales wortende erreicht")
			var wortende_x = check_x
			var length_of_word = wortende_x - wortbeginn_x
			var gesuchtes_wort = global_concepts.wortliste_txt.substr(wortbeginn_x, length_of_word)
			
			if not wort.strip_edges() == gesuchtes_wort:
				
				var allow_wort = hat_alle_buchstaben(fehlende_buchstaben, debug_computer_buchstaben)
				if allow_wort:
					moegliche_woerter.append([gesuchtes_wort, lege_dict, wortrichtung])
					#print("mögliches wort ", gesuchtes_wort)
				#else:
					#print("nicht erlaubt", gesuchtes_wort)
			suche_start_x = wortende_x
		else:  # gewaltsamer abbruch
			#print("gewaltsamer abbruch")
			suche_start_x = find_x + 2
		
		find_x = global_concepts.wortliste_txt.find(wort, suche_start_x)
		
	
			
	return moegliche_woerter
	
func hat_alle_buchstaben(fehlende_buchstaben, debug_computer_buchstaben):
	fehlende_buchstaben.sort()
	for buchst in fehlende_buchstaben:
		if buchst not in debug_computer_buchstaben:
			return false
		if fehlende_buchstaben.count(buchst) > debug_computer_buchstaben.count(buchst):
			return false  # nicht dieselbe anzahl vorhanden
	return true


func _process(delta: float) -> void:
	if aktiv:
		#print("aktiv", aktiv)
			
		durchgang += 1
		percent = durchgang/max_durchgaenge
		draw_bar()
		think()
		if durchgang >= max_durchgaenge:
			print("ende computerzug")
			global_concepts.change_an_der_reihe()
		
