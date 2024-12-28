extends Node

@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"


func _ready() -> void:
	
	global_concepts.init_spielfeld()
	#GlobalConcepts.player.ziehe_steine() 
	
	var allowed_felder = global_concepts.get_allowed_spielfelder()
	global_concepts.set_allowed_spielfelder(allowed_felder)
	
	## DEBUG
	
		
		
	#global_concepts.wortliste.start_pruefe_wortliste()
	#global_concepts.show_popup(["Option 1", "Option 2", "Option 3"])
	#var matches_txt = global_concepts.regex_operation("RU.N.{0,1}")
	#for mat_txt in matches_txt:
		#print(mat_txt)
