extends TextureButton
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"




func _on_button_down() -> void:
	$Label.position.y += 2


func _on_button_up() -> void:
	$Label.position.y -= 2
	global_concepts.zug_beenden()
