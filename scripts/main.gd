extends Node


func _ready() -> void:
	
	GlobalConcepts.init_spielfeld()
	GlobalConcepts.player_hand.ziehe_steine() 
	
	GlobalConcepts.set_allowed_spielfelder()
#
#func _process(delta: float) -> void:
	#var fresh = GlobalConcepts.get_frisch_belegte_felder()
	#print(len(fresh))
	
