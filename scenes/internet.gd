extends HTTPRequest

var pruefe_wortliste_aktiv = false
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"

var pruefe_wortliste_nr = 0
var internet_anfrage_aktiv = false
var next_wort
var next_erlaeuterung

func _ready() -> void:
	connect("request_completed", Callable(self, "_on_request_completed"))
	
func start_pruefe_wortliste():
	pruefe_wortliste_nr = 0
	pruefe_wortliste_aktiv = true
	global_concepts.ui_info_label.visible = true

func stop_pruefe_wortliste():
	pruefe_wortliste_aktiv = false
	global_concepts.ui_info_label.visible = false

func _process(delta: float) -> void:
	if pruefe_wortliste_aktiv and not internet_anfrage_aktiv:
		
			
		next_wort = global_concepts.wortliste_dict.keys()[pruefe_wortliste_nr]
		next_erlaeuterung = global_concepts.wortliste_dict[next_wort]
		#var url = "https://de.wiktionary.org/w/api.php?action=query&format=json&list=search&srsearch=" + next_wort
		var url = "https://de.wiktionary.org/w/index.php?search=" + next_wort + "&title=Spezial%3ASuche&go=Seite"
		request(url)
		internet_anfrage_aktiv = true
		global_concepts.ui_info_label.text = "Checking " + next_wort + " (" + str(pruefe_wortliste_nr) + "/" + str(len(global_concepts.wortliste_dict.keys())) + ")"
		
func _on_request_completed(result, response_code, headers, body):
	internet_anfrage_aktiv = false
	var message 
	if result == HTTPRequest.RESULT_SUCCESS:
		var html = body.get_string_from_utf8()
		# todo: erklärung extrahieren und in datei speichern!
		message = next_wort + ": " + next_erlaeuterung 
		print(message)
		#internet_info_label.text = message 
	else:
		message = "Fehler bei der Anfrage: " + result + " ... betrifft " + next_wort
		print(message)
	pruefe_wortliste_nr += 1
	if pruefe_wortliste_nr >= len(global_concepts.wortliste_dict.keys()):
		print("alle wörter überprüft")
		
		stop_pruefe_wortliste()
		
