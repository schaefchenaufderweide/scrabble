extends Node


func _ready() -> void:
	
	GlobalConcepts.init_spielfeld()
	print("ruft ziehe steine auf")
	GlobalConcepts.player_hand.ziehe_steine() 
	print(GlobalConcepts.player_hand.steine)
	
