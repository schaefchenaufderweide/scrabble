extends TextureButton

@onready var label = $Label
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"
var art
var info

func _on_button_down() -> void:
	if label:
		label.position.y += 2
	#print("press")
	
	
func _on_button_up() -> void:
	var label_text
	if label:
		label.position.y -= 2  # damit es wirkt wie label auch hineingedrückt
		label_text = label.text
	else:
		label_text = null
	global_concepts.close_popup(label_text, art, info)
