extends TextureButton

@onready var label = $Label
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"
var art
var info

func _on_button_down() -> void:
	$Label.position.y += 2
	#print("press")
	
	
func _on_button_up() -> void:
	$Label.position.y -= 2  # damit es wirkt wie label auch hineingedrückt
	global_concepts.close_popup(label.text, art, info)
