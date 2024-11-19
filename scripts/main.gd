extends Node

@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"

func _ready() -> void:
	
	global_concepts.init_spielfeld()
	#GlobalConcepts.player.ziehe_steine() 
	
	var allowed_felder = global_concepts.get_allowed_spielfelder()
	global_concepts.set_allowed_spielfelder(allowed_felder)
	
	#check_moegliche_woerter_dict()
	
#func check_moegliche_woerter_dict():
	## überprüfen des dictionarys, welche wörter mit jedem wort gelegt werden können
	#var einzelwoerter = global_concepts.wortliste_txt.split("\n")
	#$LoadingLabel.visible = true
	#
	#for wort in einzelwoerter:
		#print(wort)
		#$LoadingLabel.text = wort
		#
		#
		#if not wort in global_concepts.moegliche_woerter_dict:
			#var moegliche_woerter = find_moegliche_woerter(wort, 0)
			#global_concepts.moegliche_woerter_dict[wort] = moegliche_woerter
			
	# TEST!!!!!!!!!!
	#1. Wörter lesen  mit einzelbuchstaben 
	#2. Welche erlaubten wörter beinhalten die gelesenen wörter inkl. Einzelbucjstaben
	#3. Welche buchstaben bräuchte ich
	#4. Welchen platz beöuchte ich
	#5. Liste möglicher wörter vor check
	#6. Check mit word array, wörter einlesen, allesamt korrekte wörter?
	#7. Punkteliste erstellen
	#8. Bestes wort wählen
	
	
	var debug_gelegte_woerter_mit_zelle_und_richtung = [["IN", [7,7], "horizontal"]]
	var debug_computer_buchstaben = ["H", "A", "B", "R", "S", "L", "P"]
	debug_computer_buchstaben.sort()
	
	
	# NORMALERWEISE MUSS DAS SO SEIN!!!var belegte_felder = global_concepts.get_belegte_felder(false)
	var debug_belegte_felder = [[7,7], [8,7]]
	
	for wort_lst in debug_gelegte_woerter_mit_zelle_und_richtung:
		var wort = wort_lst[0]
		var zelle_beginn = wort_lst[1]
		var richtung
		if wort_lst[2] == "horizontal":
			richtung = [1, 0]
		else:
			richtung = [0, 1]
		
		
		if wort in global_concepts.wortliste_txt:
			var moegliche_woerter = find_moegliche_woerter(wort, 0, debug_computer_buchstaben, zelle_beginn, richtung, debug_belegte_felder)
			
func is_a_letter(letter):
	
	var allowed = letter in GlobalGameSettings.allowed_letters # (letter.unicode_at(0) >= 65 and letter.unicode_at(0) <= 90) or letter in ["Ä", "Ö", "Ü"]
	return allowed

func find_moegliche_woerter(wort, suche_start_x, debug_computer_buchstaben, wortbeginn_zelle, wortrichtung, belegte_felder):
	
	# TODO verbesserungen: var abbruch - wenn buchstaben verlangt, aber nicht vorhanden oder zelle.x oder zelle.y < 0 oder > 15, dann find_x setzen und weiter
	
	
	
	var moegliche_woerter = []
	
	var find_x = global_concepts.wortliste_txt.find(wort, suche_start_x)
	
	while find_x != -1:
		var fehlende_buchstaben = []
		var check_x = find_x - 1
		var letter = global_concepts.wortliste_txt[check_x]
		# wortbeginn suchen
		
		
		#print("A".unicode_at(0))
		#print("Z".unicode_at(0))
		while is_a_letter(letter):
			var abstand_von_beginn = check_x - find_x 
			var zelle = [wortbeginn_zelle[0] + wortrichtung[0] * abstand_von_beginn, wortbeginn_zelle[1] + wortrichtung[1] * abstand_von_beginn]
			if zelle in belegte_felder:
				print(zelle, " ist belegt")
				
			else:
				fehlende_buchstaben.append(letter)
			check_x -= 1
			letter = global_concepts.wortliste_txt[check_x]
			
		var wortbeginn_x = check_x + 1
		
		# wortende suchen
		check_x = find_x + 1
		letter = global_concepts.wortliste_txt[check_x]
		#var length_of_word = 0
		while is_a_letter(letter):
			var abstand_von_beginn = check_x - find_x 
			var zelle = [wortbeginn_zelle[0] + wortrichtung[0] * abstand_von_beginn, wortbeginn_zelle[1] + wortrichtung[1] * abstand_von_beginn]
			if not zelle in belegte_felder:
				
				fehlende_buchstaben.append(letter)
			#length_of_word += 1
			check_x += 1
			letter = global_concepts.wortliste_txt[check_x]
		var wortende_x = check_x
		var length_of_word = wortende_x - wortbeginn_x
		var gesuchtes_wort = global_concepts.wortliste_txt.substr(wortbeginn_x, length_of_word)
		
		if not wort.strip_edges() == gesuchtes_wort:
			
			var allow_wort = hat_alle_buchstaben(fehlende_buchstaben, debug_computer_buchstaben)
			if allow_wort:
				moegliche_woerter.append(gesuchtes_wort)
				print("mögliches wort ", gesuchtes_wort)
			#else:
				#print("nicht erlaubt", gesuchtes_wort)
		suche_start_x = wortende_x
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
				
			#else:
				#print("mögliches wort ", gesuchtes_wort, " nicht möglich")
			
#func _process(delta: float) -> void:
	#print(global_concepts.an_der_reihe)
	
	
	
