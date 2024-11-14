extends Node


func _ready() -> void:
	
	GlobalConcepts.init_spielfeld()
	GlobalConcepts.player_hand.ziehe_steine() 
	
	
	
