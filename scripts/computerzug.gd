extends Node

var aktiv = false
var durchgang: float = 0.0  # ich muss sie als float definieren, da gd script scheiße ist
var max_durchgaenge: float = 0.0
var faktor_fake_durchgang = 100
var fake_durchgang:float = 0.0  # pseudozahl: durchgang * faktor_fake, um glattere wartebar zu generieren ich muss sie als float markieren, weil gd script scheiße ist




@onready var computer_fortschritt: Sprite2D = $"/root/Main/UICanvasLayer/ComputerFortschritt"

@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"

#var word_array
var moegliche_woerter = []
var zu_pruefende_reihen = []
var zu_pruefende_spalten = []
var computer_buchstaben = []
var belegte_felder = []
var word_array_waagrecht = []
var word_array_senkrecht = []

var known_matches = {}

var thread: Thread
var thread_aktiv = false

func _ready() -> void:
	computer_fortschritt.visible = false
	thread = Thread.new()
	
func _process(_delta: float) -> void:
	
	if aktiv:
		
			
		
		if thread_aktiv:
			count_fake_durchgang_and_draw_bar()
			pass
			
		elif zu_pruefende_reihen:
			thread.wait_to_finish()
			var zu_pruefende_reihe = zu_pruefende_reihen.pop_front()
			thread.start(Callable(self, "think_durchgang").bind(zu_pruefende_reihe, "reihe"))
			thread_aktiv = true
			#print("thread gestartet!")
			durchgang += 1
			
			#percent = durchgang/max_durchgaenge
			#draw_bar()
			#think_durchgang(zu_pruefende_reihe, "reihe", belegte_felder)
		elif zu_pruefende_spalten:
			thread.wait_to_finish()
			var zu_pruefende_spalte = zu_pruefende_spalten.pop_front()
			thread.start(Callable(self, "think_durchgang").bind(zu_pruefende_spalte, "spalte"))
			thread_aktiv = true
			#print("thread gestartet!")
			durchgang += 1
			#percent = durchgang/max_durchgaenge
			#draw_bar()
			#think_durchgang(zu_pruefende_spalte, "spalte", belegte_felder)
			
		else:
			thinking_ende()
	

func restart():
	#print("restart computerzug")
	moegliche_woerter = []
	computer_fortschritt.visible = true
	aktiv = true
	durchgang = 0
	fake_durchgang = 0
	thread_aktiv = false
	zu_pruefende_reihen = []
	zu_pruefende_spalten = []
	
	
	belegte_felder = global_concepts.get_belegte_felder(false)
	
	
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
	
	if not belegte_felder:
		global_concepts.brett_ist_leer = true
	else:
		global_concepts.brett_ist_leer = false
		
	var word_array_lst = get_word_array(belegte_felder)
	word_array_waagrecht = word_array_lst[0]
	word_array_senkrecht = word_array_lst[1]
	
	#print("zu prüfende reihen: ", zu_pruefende_spalten, " zu prüfende spalten: ", zu_pruefende_spalten)
	
func count_fake_durchgang_and_draw_bar():
	if fake_durchgang < durchgang * faktor_fake_durchgang:
		var fehlen_auf_soll = (durchgang * faktor_fake_durchgang) - fake_durchgang
		var wahrscheinlichkeit
		var add 
		if fehlen_auf_soll > faktor_fake_durchgang / 2:
			wahrscheinlichkeit = 100
			add = 4
		elif fehlen_auf_soll > faktor_fake_durchgang / 3:
			wahrscheinlichkeit = 80
			add = 3
		elif fehlen_auf_soll > faktor_fake_durchgang / 4:
			wahrscheinlichkeit = 50
			add = 2
		elif fehlen_auf_soll > faktor_fake_durchgang / 5:
			wahrscheinlichkeit = 40
			add = 1
		else:
			wahrscheinlichkeit = 40
			add = 1
		if randi_range(0, 100) < wahrscheinlichkeit:
			fake_durchgang += add
	var percent: float = fake_durchgang/(max_durchgaenge * faktor_fake_durchgang)
	#print(fake_durchgang, "/", max_durchgaenge * faktor_fake_durchgang, " ", percent)
	
	computer_fortschritt.change_value(percent)
	

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
	
	
	
	
func think_durchgang(zu_pruefende_reihe_oder_spalte_nr, info_reihe_oder_spalte_txt):
	#print("start think durchgang ...")
	#var timer_start = Time.get_ticks_msec()
	var zu_pruefende_reihe_oder_spalte_txt = ""
	if info_reihe_oder_spalte_txt == "reihe":
		zu_pruefende_reihe_oder_spalte_txt = word_array_waagrecht[zu_pruefende_reihe_oder_spalte_nr]
	elif info_reihe_oder_spalte_txt == "spalte":
		zu_pruefende_reihe_oder_spalte_txt = word_array_senkrecht[zu_pruefende_reihe_oder_spalte_nr]
	
	
	
	var all_lst = get_words_and_zellen_from_string_and_patterns(zu_pruefende_reihe_oder_spalte_txt)
	var alle_worter_all = all_lst[0]
	var patterns = all_lst[1]
	
	# DEBUG
	#var patterns = [".{0,5}A.{0,4}", ".{0,2}N.{0,1}"]
	
	for pattern in patterns:
		moegliche_woerter += find_moegliche_woerter(pattern, computer_buchstaben, alle_worter_all, info_reihe_oder_spalte_txt, zu_pruefende_reihe_oder_spalte_nr)
	#print("Dauer eines kompletten Durchgangs: ", Time.get_ticks_msec() - timer_start)
	#print("ende think durchgang")
	#print("Vor thread_aktiv = false: thread_aktiv = ", thread_aktiv)
	thread_aktiv = false
	#print("Nach thread_aktiv = false: thread_aktiv = ", thread_aktiv)

#
#func get_words_and_zellen_from_string_and_patterns(text):
	#var alle_woerter = text.split(" ", false)
	#var wort_anfaenge_dict = {}
	#var ab_wann_suchen = 0
	#for wort in alle_woerter:
		#var wortanfang = text.find(wort, ab_wann_suchen)
		#
		#wort_anfaenge_dict[wort] = wortanfang
		#ab_wann_suchen = wortanfang + 1
	#
	#
	#var big_pattern = ""
	#ab_wann_suchen = 0
	#for wort_nr in range(alle_woerter):
		#var wort = alle_woerter[wort_nr]
		#var single_pattern = ""
		#var wortbeginn = wort_anfaenge_dict[wort]
		#var wortbeginn_next
		#var sub = text.substr(0, wortbeginn)
		#var abstand_vorn = sub.count(" ")
		#var abstand_hinten
		#if wort_nr == 0:
			#big_pattern += ".{0," + str(abstand) + "}" + wort
			##abstand_vorn = wortbeginn
		#elif wort_nr == len(alle_woerter) - 1:  # letztes wort
			#wortbeginn_next = GlobalGameSettings.anzahl_felder 
		#else:
			#var next_wort = alle_woerter[wort_nr + 1]
			#wortbeginn_next = wort_anfaenge_dict[next_wort] 
		#
		#
		#if wort != alle_woerter[0] and wort != alle_woerter[-1]:
			#abstand -= 1
		#big_pattern += ".{0," + str(abstand) + "}" + wort
		#
		#if wort == alle_woerter[0]:
			#single_pattern = ".{0," + str(abstand) + "}" + wort + 
		#
		#ab_wann_suchen = wortbeginn + len(wort)
		#
		
		
		
func get_words_and_zellen_from_string_and_patterns(text):
	#var timer_start = Time.get_ticks_msec()
	#var wort_anfaenge_dict = {}
	var alle_woerter = text.split(" ", false)
	var alle_woerter_all = []
	var big_pattern = ""
	var patterns = []
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
				alle_woerter_all.append([new_wort, wortbeginn_stelle])
				#wort_anfaenge_dict[new_wort] = wortbeginn_stelle
				new_wort = ""
				wortbeginn_stelle = null
				#new_wort_dict = {}
			leerzeichen += 1
		else:
			if not new_wort:  # aufzeichnung beginnt
				big_pattern += ".{0," + str(leerzeichen) +  "}"
				leerzeichen = 0
				wortbeginn_stelle = stelle
			big_pattern += buchstabe
			
			#new_wort_dict[zelle] = buchstabe
			new_wort += buchstabe
			
			
				
		stelle += 1
		if stelle >= len(text):
			
			break
		
	big_pattern += ".{0," + str(leerzeichen) + "}"
	
	patterns.append(big_pattern)
	
	
	if len(alle_woerter_all) > 1:
		for wort_nr in range(len(alle_woerter_all)):
			var wort = alle_woerter_all[wort_nr][0]
			var wortbeginn = alle_woerter_all[wort_nr][1]
			var wortende = wortbeginn + len(wort)
			var wortende_prev
			var wortbeginn_next 
			
			
			var single_pattern = ""
			
			if wort_nr == 0:
				wortende_prev = 0
			if wort_nr == len(alle_woerter_all) - 1: # letztes
				wortbeginn_next = GlobalGameSettings.anzahl_felder
			
			if wortbeginn_next == null:
				var next_wort = alle_woerter_all[wort_nr + 1][0]
				wortbeginn_next = alle_woerter_all[wort_nr + 1][1] - 1
			if wortende_prev == null:
				var last_wort = alle_woerter_all[wort_nr - 1][0]
				wortende_prev = alle_woerter_all[wort_nr - 1][1] + len(last_wort) + 1
			var abst_vorn = wortbeginn - wortende_prev
			var abst_hinten = wortbeginn_next - wortende
			if abst_vorn < 0 or abst_hinten < 0:
				pass
			
			single_pattern = ".{0," + str(abst_vorn) + "}" + wort + ".{0," + str(abst_hinten) + "}"
			if not single_pattern in patterns:
				patterns.append(single_pattern)
	
	return [alle_woerter_all, patterns]

func find_moegliche_woerter(pattern, computer_buchstaben, alle_woerter_all, info_waag_oder_senkrecht, reihe_oder_spalte_nr):
	#print("start finde wörter")
	#var timer_start = Time.get_ticks_msec()
	#var woerter_in_reihe_oder_spalte = get_words_and_zellen_from_string(zu_pruefende_reihe_oder_spalte_txt)
	
	var moegliche_woerter = []
	#print("buchstaben: ", computer_buchstaben)
	#var timer_start = Time.get_ticks_msec()
	var matches_txt
	
	if pattern + str(computer_buchstaben.count("?")) in known_matches:
		matches_txt = known_matches[pattern + str(computer_buchstaben.count("?"))]
		#print("known pattern ", pattern) 
	else: 
		#print("starte regex mit ", pattern)
		matches_txt = global_concepts.regex_operation(pattern)
		known_matches[pattern + str(computer_buchstaben.count("?"))] = matches_txt
		#print("pattern saved: ", pattern)
			
	if not matches_txt:
		#print("Keine Matches gefunden!")
		return []
		
		
	for single_match_txt in matches_txt:  # suche bei völlig neuem spielfeld
		if not single_match_txt in global_concepts.wortliste_dict:
			continue
		
		var wortbeginn_wort
		
		
		if not alle_woerter_all: # neues spiel - leeres brett, computer legt nur waagrecht
			var fehlende_buchstaben = single_match_txt.split()
			var ergebnis_hat_alle_buchstaben = hat_alle_buchstaben(fehlende_buchstaben, computer_buchstaben)
			var erlaubt = ergebnis_hat_alle_buchstaben[0]
			var verwendet_fragezeichen = ergebnis_hat_alle_buchstaben[1]
			if not erlaubt:
				continue
			var lege_dict = get_lege_dict_for_new_game(single_match_txt)
			var richtung = [1,0]
			assert(single_match_txt in global_concepts.wortliste_dict)
			moegliche_woerter.append([single_match_txt, lege_dict, richtung, verwendet_fragezeichen])
			continue
		
		# kein leeres brett
		for wort_lst in alle_woerter_all:
			
			var wort = wort_lst[0]
			if wort == single_match_txt:
				continue
			
			
			
			var teilwort_beginn = wort_lst[1]
			var alle_stellen = []
			var suche_stelle_beginn = 0
			while true:  # so lange stellen suchen bis keine mehr zu finden
				var new_stelle = single_match_txt.find(wort, suche_stelle_beginn)
				if new_stelle == -1:
					break
				else:
					alle_stellen.append(new_stelle)
					suche_stelle_beginn = new_stelle + 1
				
				#var stelle_in_woerterbuch_wort = single_match_txt.find(wort)
			
			for stelle in alle_stellen:
				
				wortbeginn_wort = teilwort_beginn - stelle
				if wortbeginn_wort < 0:
					
					continue
				
				if wortbeginn_wort + len(single_match_txt) >= GlobalGameSettings.anzahl_felder:
					
					
					
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
				var ergebnis_lege_dict = get_lege_dict(single_match_txt, zelle_beginn, richtung)
				var lege_dict = ergebnis_lege_dict[0]
				var verwendet_fragezeichen = ergebnis_lege_dict[1]

				
				
				if lege_dict:
					#print("möglich: ", single_match_txt)
					#print("singlematch_txt stripped: ", single_match_txt, "singlematch_txt: ", single_match.get_string())
					assert(single_match_txt in global_concepts.wortliste_dict)
					moegliche_woerter.append([single_match_txt, lege_dict, richtung, verwendet_fragezeichen])
				#else:
					#print(single_match_txt, " nicht möglich!")
			#print("Dauer: ", Time.get_ticks_msec() - timer_start)
		#print("Dauer: ", Time.get_ticks_msec() - timer_start)
	return moegliche_woerter
	
		
		

func get_lege_dict_for_new_game(single_match_txt):
	
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
			assert(zelle in global_concepts.all_spielfelder)  # das sollte nicht mehr vorkommen!
				
			lege_dict[zelle] = buchstabe
			#if not buchstabe in computer_buchstaben:
				#
				#return false
			fehlende_buchstaben.append(buchstabe)
		abstand += 1
	if not fehlende_buchstaben:  # ist ident mit bereits gelegtem
		return [false, false] 
	var ergebnis_hat_alle_buchstaben = hat_alle_buchstaben(fehlende_buchstaben, computer_buchstaben)
	var erlaubt = ergebnis_hat_alle_buchstaben[0]
	var verwendet_fragezeichen = ergebnis_hat_alle_buchstaben[1]
	if not erlaubt:
		return [false, false]

	return [lege_dict, verwendet_fragezeichen]


func sort_by_punkte(woerter):
	woerter.sort_custom(func(a, b): return a[1] > b[1])
	return woerter

func test_moegliches_wort_und_get_punkte_und_get_punkte_labels(wort_dict):
	"""
	hier wird geprüft, ob die wörter tatsächlich so gelegt werden können
	außerdem werden die punkte ermittelt
	"""
	#var timer_start = Time.get_ticks_msec()
	
	#var wort = wort_dict[0]
	var zu_legende_buchstaben_dict = wort_dict[1]
	var verwendet_fragezeichen = wort_dict[3]
	#var alle_buchstaben_gelegt_bonus 
	#if len(zu_legende_buchstaben_dict) == GlobalGameSettings.anzahl_steine_pro_hand:
		#alle_buchstaben_gelegt_bonus = 50
	#else:
		#alle_buchstaben_gelegt_bonus = 0
			#
	var alle_woerter = global_concepts.read_gelegte_woerter(zu_legende_buchstaben_dict)
	if not global_concepts.is_zug_gueltig(true, alle_woerter):
		return [false, 0, null]
	
	var fragezeichen_zellen
	if verwendet_fragezeichen:
		fragezeichen_zellen = find_fragezeichen_zellen(zu_legende_buchstaben_dict)
	else:
		fragezeichen_zellen = []
	
	var ergebnis = global_concepts.get_punkte(alle_woerter, zu_legende_buchstaben_dict.keys(), fragezeichen_zellen)
	var punkte = ergebnis[0]
	var new_punkte_labels = ergebnis[1]
	#print(wort, " würde ", punkte, " bringen")
	#print("Dauer: ", Time.get_ticks_msec() - timer_start)
	return [true, punkte, new_punkte_labels]

func find_fragezeichen_zellen(zu_legende_buchstaben_dict):
	var fragezeichen_zellen = []
	var computer_buchstaben_dict_for_fragezeichen = {}
	for zelle in zu_legende_buchstaben_dict:
		var buchst = zu_legende_buchstaben_dict[zelle]
		if not computer_buchstaben_dict_for_fragezeichen.get(buchst):
			computer_buchstaben_dict_for_fragezeichen[buchst] = computer_buchstaben.count(buchst)
		
		if computer_buchstaben_dict_for_fragezeichen[buchst] == 0:
			fragezeichen_zellen.append(zelle)
		else:
			computer_buchstaben_dict_for_fragezeichen[buchst] -= 1
				
	return fragezeichen_zellen
#func hat_alle_buchstaben(fehlende_buchstaben, computer_buchstaben):
	#var computer_buchstaben_dict = {}
	#for buchst in computer_buchstaben:
		#if buchst in computer_buchstaben_dict:
			#continue
		#computer_buchstaben_dict[buchst] = computer_buchstaben.count(buchst)
	#
	#var fehlende_buchstaben_dict = {}
	#for buchst in fehlende_buchstaben:
		#if buchst in fehlende_buchstaben_dict:
			#continue
		#fehlende_buchstaben_dict[buchst] = fehlende_buchstaben.count(buchst)
		#if not computer_buchstaben_dict.get(buchst):
			#computer_buchstaben_dict[buchst] = 0
	#
	#for buchst in fehlende_buchstaben_dict:
		#var notwendig = fehlende_buchstaben_dict[buchst]
		#
		#var vorhanden = computer_buchstaben_dict[buchst]
		#computer_buchstaben_dict[buchst] -= notwendig
		#while computer_buchstaben_dict[buchst] < 0:
			#var fragezeichen_vorhanden = computer_buchstaben_dict.get("?")
			#if not fragezeichen_vorhanden:
				#return false
			#computer_buchstaben_dict["?"] -= 1
			#computer_buchstaben_dict[buchst] += 1
		#
	#
func hat_alle_buchstaben(fehlende_buchstaben, computer_buchstaben):
	if len(fehlende_buchstaben) > len(computer_buchstaben):
		return [false, false]
	var uses_fragezeichen = false
	var check_computer_buchstaben = computer_buchstaben.duplicate()
	fehlende_buchstaben = Array(fehlende_buchstaben)
	
	for buch in fehlende_buchstaben:
		#print("verbliebene: ", check_computer_buchstaben)
		if buch in check_computer_buchstaben:
			check_computer_buchstaben.erase(buch)
		elif "?" in check_computer_buchstaben:
			check_computer_buchstaben.erase("?")
			uses_fragezeichen = true
			
		else:
			#print("fehlendes ", buch)
			return [false, false]
	return [true, uses_fragezeichen]
	
func hat_alle_buchstaben_old(fehlende_buchstaben, computer_buchstaben):
	var uses_fragezeichen = false
	#var fragezeichen_zur_verfuegung = computer_buchstaben.count("?")
	#var eingesetzte_fragezeichen = {}
	fehlende_buchstaben.sort()
	var fehlende_buchstaben_check_two = fehlende_buchstaben.duplicate()
	var stelle = 0
	for buchst in fehlende_buchstaben:
		#eingesetzte_fragezeichen[buchst] = 0
		
		if buchst not in computer_buchstaben and not "?" in computer_buchstaben:
			return [false, false]
		if buchst not in computer_buchstaben:
			fehlende_buchstaben_check_two[stelle] = "?"
			uses_fragezeichen = true
		stelle += 1
	for buchst in fehlende_buchstaben_check_two:
		if fehlende_buchstaben_check_two.count(buchst) > computer_buchstaben.count(buchst): 
			#print("... kann nicht geschrieben werden, nicht genug ", buchst)
			return [false, false]  # nicht dieselbe anzahl vorhanden
	#print(" ... kann geschrieben werden")
	return [true, uses_fragezeichen]


func thinking_ende():
	var erlaubte_woerter = []
	for pruefwort_lst in moegliche_woerter:
		assert(pruefwort_lst[0] in global_concepts.wortliste_dict)
			
		var ergebnis_test = test_moegliches_wort_und_get_punkte_und_get_punkte_labels(pruefwort_lst)
		var allowed = ergebnis_test[0]
		
		var punkte = ergebnis_test[1] 
		var new_punkte_labels = ergebnis_test[2]
		if allowed:
			erlaubte_woerter.append([pruefwort_lst, punkte, new_punkte_labels])
			
	
	var sort_erlaubte_woerter = sort_by_punkte(erlaubte_woerter)
	
	if not sort_erlaubte_woerter and global_concepts.buchstaben_im_sackerl:
		var zurueck_ins_sackerl = []
		for buch in computer_buchstaben:
			if GlobalGameSettings.spielsteine_start[buch]["Wert"] > GlobalGameSettings.computer_tausch_schwelle_wert:
				zurueck_ins_sackerl.append(buch)
				var buch_position_in_hand = computer_buchstaben.find(buch)
				
				global_concepts.computer.steine_dict[buch_position_in_hand] = null
		global_concepts.buchstaben_im_sackerl += zurueck_ins_sackerl
		var tausch_text = "Computer tauscht " + str(len(zurueck_ins_sackerl)) + " Buchstaben ..."
		global_concepts.punkte_labels[[7,7]] = [tausch_text]
		#print("Computer tauscht ...")
		
		
	elif not sort_erlaubte_woerter:
		global_concepts.punkte_labels[[7,7]] = ["Computer passt ..."]
		if not global_concepts.buchstaben_im_sackerl:
			global_concepts.last_round = true
		#print("Computer passt ... (Buchstaben: ", computer_buchstaben, ")")
		
	else:
		global_concepts.last_round = false
		var gewaehltes_wort_nr_max: int
		var gewaehltes_wort_nr: int 
		var difficulty_setting = global_concepts.difficulty_slider.value
		if  difficulty_setting == 0:
			gewaehltes_wort_nr_max = len(sort_erlaubte_woerter) - 1
		elif difficulty_setting == 1:
			gewaehltes_wort_nr_max = (len(sort_erlaubte_woerter) - 1) / 3
		elif difficulty_setting == 2:
			gewaehltes_wort_nr_max = (len(sort_erlaubte_woerter) - 1) / 5
		elif difficulty_setting == 3:
			gewaehltes_wort_nr_max = 2
		elif difficulty_setting == 4:
			gewaehltes_wort_nr_max = 0
		
		if gewaehltes_wort_nr_max == 0:
			gewaehltes_wort_nr = 0
		
		elif gewaehltes_wort_nr_max > len(sort_erlaubte_woerter) - 1:
			gewaehltes_wort_nr_max = len(sort_erlaubte_woerter) - 1
		
		gewaehltes_wort_nr = randi_range(0, gewaehltes_wort_nr_max)
		var gewaehltes_wort = sort_erlaubte_woerter[gewaehltes_wort_nr]
		#print("gewaehlt_nr:", gewaehltes_wort_nr)
		#var gewaehltes_wort = sort_erlaubte_woerter[0]
		var punkte = gewaehltes_wort[1]
		lege_steine(gewaehltes_wort)
		#var punkte = sort_erlaubte_woerter[0][1]
		var new_punkte_labels = sort_erlaubte_woerter[0][2]
		for lab in new_punkte_labels:
			global_concepts.punkte_labels[lab] = new_punkte_labels[lab]
		
		#var first_feld = sort_erlaubte_woerter[0][0][1].keys()[0]
		#global_concepts.create_punkte_label(first_feld, punkte)
		global_concepts.computer.add_punkte(punkte) # .punkte += punkte 
		#print("Computer erhält ", punkte, " Punkte für ", sort_erlaubte_woerter[0][0])
		
	aktiv = false
	global_concepts.change_an_der_reihe()
			
			

func lege_steine(wort_arr):
	
	var steine_pos_dict = wort_arr[0][1]
	#var computer_steine = global_concepts.computer.steine_dict
	var rel_stein_aus_hand = null
	
	for stein_pos in steine_pos_dict:
		# suchen des richtigen steins in der computerhand	
		var gesuchter_buchstabe = steine_pos_dict[stein_pos]
		rel_stein_aus_hand = find_stein_in_hand(gesuchter_buchstabe)
	
		if not rel_stein_aus_hand:
			rel_stein_aus_hand = find_stein_in_hand("?")  # es wird ein fragezeichen gesucht
		
		assert(rel_stein_aus_hand)
		
		rel_stein_aus_hand.label_buchstabe.text = gesuchter_buchstabe
		#for stein_nr in range(GlobalGameSettings.anzahl_steine_pro_hand):
			#var test_stein = global_concepts.computer.steine_dict[stein_nr]
			#if not test_stein: # schon ausgespielt
				#continue
			#if test_stein.label_buchstabe.text == gesuchter_buchstabe:
				#global_concepts.computer.steine_dict[stein_nr] = null
				#rel_stein_aus_hand = test_stein
				#break
		
			
		
		
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
		
	
func find_stein_in_hand(gesuchter_buchstabe):
	for stein_nr in range(GlobalGameSettings.anzahl_steine_pro_hand):
			var test_stein = global_concepts.computer.steine_dict[stein_nr]
			if not test_stein: # schon ausgespielt
				continue
			if test_stein.label_buchstabe.text == gesuchter_buchstabe:
				global_concepts.computer.steine_dict[stein_nr] = null
				return test_stein
	
