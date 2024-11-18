extends Node

var aktiv = false
var durchgang:float = 0.0
var max_durchgaenge = GlobalGameSettings.computer_denktiefe
@onready var computerdenkt_fortschrittanzeige: ColorRect = $"/root/Main/UICanvasLayer/ZugBeenden/ComputerdenktFortschrittanzeige"
@onready var fortschrittanzeige_max_breite = computerdenkt_fortschrittanzeige.size.x
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"

func _ready() -> void:
	computerdenkt_fortschrittanzeige.visible = false
	

func _process(delta: float) -> void:
	if aktiv:
		print("aktiv", aktiv)
		if durchgang >= max_durchgaenge:
			aktiv = false
			print("ende computerzug")
			global_concepts.change_an_der_reihe()
			
			
		durchgang += 1
		var new_breite = fortschrittanzeige_max_breite * (durchgang/max_durchgaenge)
		#print(new_breite)
		print("Durchgang", durchgang, "/", max_durchgaenge)
		#print("computer zug aktiv")
		computerdenkt_fortschrittanzeige.size.x = new_breite
		
