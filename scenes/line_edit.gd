extends LineEdit
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"


func _on_focus_exited() -> void:
	visible = false
	global_concepts.player.rel_punkte_label.visible = true




	

func _on_text_submitted(new_text: String) -> void:
	visible = false
	global_concepts.player.name_of_party = text
	global_concepts.player.update_text()
	global_concepts.player.rel_punkte_label.visible = true

	
