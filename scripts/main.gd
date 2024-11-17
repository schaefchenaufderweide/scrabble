extends Node


func _ready() -> void:
	
	GlobalConcepts.init_spielfeld()
	#GlobalConcepts.player.ziehe_steine() 
	
	GlobalConcepts.set_allowed_spielfelder()


func _process(delta: float) -> void:
	#
	#print(GlobalConcepts.an_der_reihe)
	if GlobalConcepts.an_der_reihe == GlobalConcepts.computer:
		GlobalConcepts.computerzug.aktiv = true
	
