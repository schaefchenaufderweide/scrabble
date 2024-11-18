extends Node

@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"

func _ready() -> void:
	
	global_concepts.init_spielfeld()
	#GlobalConcepts.player.ziehe_steine() 
	
	global_concepts.set_allowed_spielfelder()


func _process(delta: float) -> void:
	print(global_concepts.an_der_reihe)
	#print(GlobalConcepts.an_der_reihe)
	if global_concepts.an_der_reihe == global_concepts.computer:
		global_concepts.computerzug.aktiv = true
	
