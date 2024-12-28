extends TextureButton

@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"

	
func _on_button_up() -> void:
	global_concepts.open_popup(["Neustart", "Schwierigkeitsgrad", "Wortliste prüfen", "Zurück"], "Optionen", null)
	
