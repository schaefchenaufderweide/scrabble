extends HSlider


@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"



func _on_value_changed(value: float) -> void:
	#value = int(value)
	global_concepts.computer.name_of_party = global_concepts.difficulties_dict[int(value)]
	global_concepts.computer.update_text()
	#print(difficulties_dict[int(value)])
	#pass # Replace with function body.


func _on_drag_ended(value_changed: bool) -> void:
	release_focus()
	visible = false
	#pass # Replace with function body.
