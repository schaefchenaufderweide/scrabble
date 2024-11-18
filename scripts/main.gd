extends Node

@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"

func _ready() -> void:
	
	global_concepts.init_spielfeld()
	#GlobalConcepts.player.ziehe_steine() 
	
	var allowed_felder = global_concepts.get_allowed_spielfelder()
	global_concepts.set_allowed_spielfelder(allowed_felder)
	
	
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
	for wort_lst in debug_gelegte_woerter_mit_zelle_und_richtung:
		var wort = wort_lst[0]
		var zelle = wort_lst[1]
		var richtung = wort_lst[2]
		
		if wort in global_concepts.wortliste:
			var moegliche_woerter = find_moegliche_woerter(wort, 0)
		
func is_a_letter(letter):
	return letter.unicode_at(0) >= 65 and letter.unicode_at(0) <= 90

func find_moegliche_woerter(wort, suche_start_x):
	# TODO NOCH HIER DIE VORHANDENEN BUCHSTABEN BERÜCKSICHTIGEN (sonst wird die liste viel zu groß!)
	
	var moegliche_woerter = []
	
	var find_x = global_concepts.wortliste.find(wort, suche_start_x)
	while find_x != -1:
		var letter = global_concepts.wortliste[find_x]
		# wortbeginn suchen
		var check_x = find_x
		
		#print("A".unicode_at(0))
		#print("Z".unicode_at(0))
		while is_a_letter(letter):
			#print(char)
			check_x -= 1
			letter = global_concepts.wortliste[check_x]
		var wortbeginn_x = check_x
		
		# wortende suchen
		check_x = find_x
		letter = global_concepts.wortliste[find_x]
		#var length_of_word = 0
		while is_a_letter(letter):
			#length_of_word += 1
			check_x += 1
			letter = global_concepts.wortliste[check_x]
		var wortende_x = check_x
		var length_of_word = wortende_x - wortbeginn_x
		var gesuchtes_wort = global_concepts.wortliste.substr(wortbeginn_x, length_of_word)
		moegliche_woerter.append(gesuchtes_wort)
		
		suche_start_x = wortende_x
		find_x = global_concepts.wortliste.find(wort, suche_start_x)
	return moegliche_woerter
	
	
			
#func _process(delta: float) -> void:
	#print(global_concepts.an_der_reihe)
	
	
	
