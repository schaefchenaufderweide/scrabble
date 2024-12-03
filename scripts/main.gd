extends Node

@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"

func _ready() -> void:
	
	global_concepts.init_spielfeld()
	#GlobalConcepts.player.ziehe_steine() 
	
	var allowed_felder = global_concepts.get_allowed_spielfelder()
	global_concepts.set_allowed_spielfelder(allowed_felder)
	
	
	## DEBUG
	#var pattern = ".{0,10}R.{0,4}\n"
	#
	#
	#var regex = RegEx.new()
	#if regex.compile(pattern) == OK:
		#var matches = regex.search_all(global_concepts.wortliste_txt)
		#if not matches:
			##print("Keine Matches gefunden!")
			#pass
		#else:
			#for sing_match in matches:
				#if sing_match.get_string()[0] == "R":
					#print(sing_match.get_string())
	#pass
