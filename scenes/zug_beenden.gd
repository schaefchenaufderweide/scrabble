extends TextureButton
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"
@onready var label = $Label
@onready var symbol_sprite: Sprite2D = $Symbol

var symbol_aktiv = "Passen"
var symbols_dict = {"Passen": preload("res://graphics/symbol_passen.png"), 
"Wort legen": preload("res://graphics/symbol_okay.png"), 
"Steine tauschen": preload("res://graphics/symbol_tauschen.png"), 
"Spielende": preload("res://graphics/symbol_spielende.png"),
"Computerzug": preload("res://graphics/symbol_wait.png"),
"ungültig": preload("res://graphics/symbol_wrong.png")}


func change_symbol(symbol_name):
	symbol_aktiv = symbol_name
	symbol_sprite.texture = symbols_dict[symbol_name]

func _on_button_down() -> void:
	symbol_sprite.position.y += 2


func _on_button_up() -> void:
	symbol_sprite.position.y -= 2  # damit es wirkt wie label auch hineingedrückt
	#print("button pressed")
	global_concepts.player_zug_beenden()
