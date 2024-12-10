extends Node

var wortliste_suchtext
var wortliste_dict
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"




	
func get_wortliste():
	
	var file = FileAccess.open("res://wortliste.txt", FileAccess.READ)
	if file:
		var wortliste_suchtext = file.get_as_text()
		
		return wortliste_suchtext
	else:
		print("Fehler beim Öffnen!!!")
		return ""
		
func get_wortliste_dict(wortliste_suchtext):

	
	var wortliste_list = wortliste_suchtext.split("\n")
	var wortliste_dict = {}
	for wort in wortliste_list:
		# todo in erklärungsdict suchen in json datei!
		var erklaerung = true # "keine Erläuterung"
		wort = wort.strip_edges()
		#erklaerung = erklaerung.strip_edges()
		if wort:
			wortliste_dict[wort] = erklaerung
			
#
	return wortliste_dict

	
	
func save_wortliste():
	var wortliste_txt_raw = ""
	var file = FileAccess.open("res://wortliste.txt", FileAccess.WRITE)
	if file:
		
		for wort in wortliste_dict.keys():
			var erklaerung = wortliste_dict[wort]
			var new_line = wort + ":" + erklaerung
			file.store_line(new_line)
		global_concepts.ui_info_label.text = "Wortliste gespeichert (" + str(len(wortliste_dict)) + " Einträge)"
	
	else:
		global_concepts.ui_info_label.text = "Fehler beim Speichern der Wortliste!"
