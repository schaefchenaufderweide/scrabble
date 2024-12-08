extends Node

@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"

func _ready() -> void:
	
	global_concepts.init_spielfeld()
	#GlobalConcepts.player.ziehe_steine() 
	
	var allowed_felder = global_concepts.get_allowed_spielfelder()
	global_concepts.set_allowed_spielfelder(allowed_felder)
	
	## DEBUG
	#global_concepts.punkte_labels = {[7,7]: ["TEST"]}
	#global_concepts.create_new_punkte_labels()
