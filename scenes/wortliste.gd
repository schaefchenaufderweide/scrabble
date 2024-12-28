extends HTTPRequest

var pruefe_wortliste_aktiv = false
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"

var pruefe_wortliste_nr = 0
var internet_anfrage_aktiv = false
var akt_zu_pruefendes_wort
var akt_erklaerung
var neue_wortliste_dict = {}

var wortliste_suchtext
var wortliste_dict


func load_wortliste_dict_and_create_wortliste_suchtext():
	var json_file = FileAccess.open("res://wortliste.json", FileAccess.READ)
	
	var data
	
	if json_file:
		var json_text = json_file.get_as_text()
		var json = JSON.new()
		var result = json.parse(json_text)
		
		if result == 0:
			wortliste_dict = json.get_data()
			#print(data)
		else:
			global_concepts.ui_info_label.text = "Fehler beim JSON-Erstellen der Wortliste"
		json_file.close()
	else:
		global_concepts.ui_info_label.text = "Fehler beim Laden der Wortliste"
	#print(", ".join(fruits)) 

	var suchtext = "\n".join(wortliste_dict.keys())
	#print(suchtext)
	return [wortliste_dict, suchtext]
	
	
	
	
func save_wortliste(new_wortliste_dict):
	# schreibe als datei
	var json_file = FileAccess.open("res://wortliste.json", FileAccess.WRITE)
	if json_file:
		
		var json = JSON.new()
		var json_text = json.stringify(new_wortliste_dict)
		json_file.store_string(json_text)
		
		json_file.close()
		global_concepts.ui_info_label.text = "Wortliste gespeichert (" + str(len(wortliste_dict)) + " Einträge)"
	else:
		global_concepts.ui_info_label.text = "Fehler beim Speichern der Wortliste!"




	
func start_pruefe_wortliste():
	connect("request_completed", Callable(self, "_on_request_completed"))
	pruefe_wortliste_nr = 0
	pruefe_wortliste_aktiv = true
	global_concepts.ui_info_label.visible = true

func stop_pruefe_wortliste():
	pruefe_wortliste_aktiv = false
	global_concepts.ui_info_label.visible = false
	
	global_concepts.wortliste.save_wortliste()
	
func _process(_delta: float) -> void:
	
	if pruefe_wortliste_aktiv and not internet_anfrage_aktiv:
		akt_zu_pruefendes_wort = global_concepts.wortliste_dict.keys()[pruefe_wortliste_nr]
		akt_erklaerung = global_concepts.wortliste_dict[akt_zu_pruefendes_wort]
		global_concepts.ui_info_label.text = "Checking " + akt_zu_pruefendes_wort + " (" + str(pruefe_wortliste_nr) + "/" + str(len(global_concepts.wortliste_dict.keys())) + ")"
		if not ist_erlaubt(akt_zu_pruefendes_wort):
			next_wort()
			return
		
		if akt_erklaerung != "Keine Erklärung gefunden":
			neue_wortliste_dict[akt_zu_pruefendes_wort] = akt_erklaerung
			var message = '"' + akt_zu_pruefendes_wort + '": "' + akt_erklaerung + '",'
			print(message)
			next_wort()
			return
			
		var internet_akt_zu_pruefendes_wort = akt_zu_pruefendes_wort.capitalize()
		
		var url = "https://de.wiktionary.org/w/index.php?search=" + internet_akt_zu_pruefendes_wort + "&title=Spezial%3ASuche&go=Seite"
		request(url)
		internet_anfrage_aktiv = true
		

func next_wort():
	internet_anfrage_aktiv = false
	pruefe_wortliste_nr += 1
	
func ist_erlaubt(wort):
	# red flags: wortlänge < 2
	# kein vokal
	# schon vorhanden
	
	if wort in neue_wortliste_dict:
		global_concepts.ui_info_label.text = wort +  " schon in Liste"
		return false
	if len(wort) < 2:
		global_concepts.ui_info_label.text = wort + " ausgeschlossen! (zu kurz)"
		return false
	
	var vokal_in_wort
	for vokal in ["A", "E", "I", "O", "U", "Ä", "Ö", "Ü"]:
		if vokal in wort:
			vokal_in_wort = true
			break
	if not vokal_in_wort:
		global_concepts.ui_info_label.text = wort + " ausgeschlossen! (kein Vokal)"
		return false
	return true

func _on_request_completed(result, _response_code, _headers, body):
	
	var message
	
	if result == HTTPRequest.RESULT_SUCCESS:
		
		
		var html = body.get_string_from_utf8()
		akt_erklaerung = get_new_erklaerung(html)
		
		message = '"' + akt_zu_pruefendes_wort + '": "' + akt_erklaerung + '",'
		neue_wortliste_dict[akt_zu_pruefendes_wort] = akt_erklaerung
		
		
	else:
		message = "Fehler bei der Anfrage: " + str(result) + " ... betrifft " + akt_zu_pruefendes_wort
		
		#akt_erklaerung = "nichts gefunden"
		
	global_concepts.ui_info_label.text = message
	print(message)
	
	if pruefe_wortliste_nr > len(global_concepts.wortliste_dict.keys()):
		global_concepts.ui_info_label.text = "alle wörter überprüft"
		
		stop_pruefe_wortliste()
	#elif pruefe_wortliste_nr % 10 == 0 and not pruefe_wortliste_nr == 0: # zwischenspeichern
		#save_wortliste(neue_wortliste_dict)
		#next_wort()	
	
	else:
		next_wort()
	
	
func get_new_erklaerung(html):
	var pattern = "Bedeutungen:</p>([\\s\\S]*?)<p"
		

	var regex = RegEx.new()
	if regex.compile(pattern) == OK:
		var matches_raw = regex.search_all(html)
		var erklaerung
		if matches_raw:
			var single_match = matches_raw[0]
		
		
			erklaerung = single_match.get_string()
			erklaerung = erklaerung.substr(0, len(erklaerung) - 2)  # löscht letzte zwei zeichen
			var length = pattern.find("<")
			erklaerung = erklaerung.substr(length)  # löscht anfang
			pattern = "<[^>]*>"# + r"|\[\d+\]" # Entfernt ALLE HTML-Tags
			
			if regex.compile(pattern) == OK:
				while regex.search(erklaerung):
					erklaerung = regex.sub(erklaerung, "")
				erklaerung = erklaerung.replace("&#58;", ":")
				erklaerung = erklaerung.replace("&#32;", " ")
				erklaerung = erklaerung.replace("☆", "")
				if "[1]" in erklaerung and not "[2]" in erklaerung:
					erklaerung = erklaerung.replace("[1]", "")
				erklaerung = erklaerung.strip_edges()
				
				return erklaerung
			else:
				print("Regex konnte nicht kompiliert werden.")
		else:
			erklaerung = find_uebereinstimmung(neue_wortliste_dict)
			return erklaerung

func find_uebereinstimmung(neue_wortliste_dict):
	var alle_uebereinstimmungen = []
	for check_wort in neue_wortliste_dict:
		
		var stelle = 0
		var uebereinstimmung: float = 0.0
		var bonus_add = 0  # hintereinander übereinstimmend
		var bonus = 0
		for char in check_wort:
			if neue_wortliste_dict[check_wort] == "Keine Erklärung gefunden":
				continue
			if stelle > len(akt_zu_pruefendes_wort) - 1:
				break
			if akt_zu_pruefendes_wort[stelle] == char:
				uebereinstimmung += 1
				bonus_add += 1
			else:
				if bonus_add > 1:
					bonus += bonus_add
				bonus_add = 0
				
			stelle += 1
		var vergleichslaenge = max(len(akt_zu_pruefendes_wort), len(check_wort))
		var aehnlichkeit: float = ((uebereinstimmung + bonus)/(vergleichslaenge + bonus)) * 100
		alle_uebereinstimmungen.append([neue_wortliste_dict[check_wort], aehnlichkeit])
			
	alle_uebereinstimmungen.sort_custom(func(a, b): return a[1] > b[1])
	var best = alle_uebereinstimmungen[0]
	if best[1] > 85:
		return best[0]
		
	else:
		return("Keine Erklärung gefunden")

		
