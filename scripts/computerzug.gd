extends Node

var aktiv = false
var durchgang:float = 0.0
var max_durchgaenge = GlobalGameSettings.computer_denktiefe
@onready var computerdenkt_fortschrittanzeige: ColorRect = $"/root/Main/UICanvasLayer/ZugBeenden/ComputerdenktFortschrittanzeige"
@onready var fortschrittanzeige_max_breite = computerdenkt_fortschrittanzeige.size.x
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"
var percent: float = 0.0
var word_array


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


# TEST!!!!!!!!!!
	#1. Wörter lesen  mit einzelbuchstaben 
	#2. Welche erlaubten wörter beinhalten die gelesenen wörter inkl. Einzelbucjstaben
	#3. Welche buchstaben bräuchte ich
	#4. Welchen platz beöuchte ich
	#5. Liste möglicher wörter vor check
	#6. Check mit word array, wörter einlesen, allesamt korrekte wörter?
	#7. Punkteliste erstellen
	#8. Bestes wort wählen
	
	
func think():
	var computer_buchstaben = get_buchstaben()

	
	
	#
	#var debug_gelegte_woerter_mit_zelle_und_richtung = [["DONAUDAMPF", [7,7], "horizontal"], ["DENNOCH", [7,7], "vertikal"], ["NILPFERDE", [7,9], "horizontal"]]
	
	computer_buchstaben.sort()
	
	
	
	var gelegte_woerter_mit_zelle_und_richtung = global_concepts.read_gelegte_woerter(true)
	
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
		
		moegliche_woerter += find_moegliche_woerter(wort, 0, computer_buchstaben, zelle_beginn, richtung, gelegte_woerter_mit_zelle_und_richtung)
		
	print("Anzahl möglicher Wörter: ", len(moegliche_woerter))
	
	var erlaubte_woerter = []
	for wort in moegliche_woerter:
		var ergebnis_test = test_moegliches_wort(wort)
		var allowed = ergebnis_test[0]
		var punkte = ergebnis_test[1]
		if allowed:
			erlaubte_woerter.append([wort, punkte])

func test_moegliches_wort(wort):
	"""
	hier wird geprüft, ob die wörter tatsächlich so gelegt werden können
	ist seitlich bzw. ober-unterhalb des probeweise gelegten buchstabens ein bereits gelegter buchstabe? 
	dann schauen, ob gültiges wort
	die legerichtung ist bereits überprüft! es geht nur um "querschläger"
	"""
	pass

	

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
					moegliche_woerter.append([gesuchtes_wort, lege_dict])
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

	##print(vorhandene_buchstaben)
	#print(global_concepts.wortliste_txt)	
	#for wort_lst in gelegte_woerter_mit_zelle_und_richtung:
		#var wort = wort_lst[0]
		#var zelle = wort_lst[1]
		#var richtung = wort_lst[2]
		#
		#if wort in global_concepts.wortliste:
			#print()
			##if wort xxx
	##
	#var erlaubte_felder = global_concepts.get_allowed_spielfelder()
	#print(erlaubte_felder)
	# TODO HIER WEITER!!! TESTEN IM MAIN!!!!
	pass
	#1. Wörter lesen  mit einzelbuchstaben 
	#2. Welche erlaubten wörter beinhalten die gelesenen wörter inkl. Einzelbucjstaben
	#3. Welche buchstaben bräuchte ich
	#4. Welchen platz beöuchte ich
	#5. Liste möglicher wörter vor check
	#6. Check mit word array, wörter einlesen, allesamt korrekte wörter?
	#7. Punkteliste erstellen
	#8. Bestes wort wählen

#func init_word_array():
	#word_array = []
	#var belegte_felder = global_concepts.get_belegte_felder()
	#print(belegte_felder)
	#for y in range(GlobalGameSettings.anzahl_felder):
		#var word_array_x_line = []
		#
		#for x in range(GlobalGameSettings.anzahl_felder):
		#
			#
			#var feld = [x, y]
			#if feld in belegte_felder:
				#word_array_x_line.append(belegte_felder[feld])
			#else:
				#word_array_x_line.append("")
		#word_array.append(word_array_x_line)
	#print(word_array)
	#

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
		
