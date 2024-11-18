extends Node

var aktiv = false
var durchgang:float = 0.0
var max_durchgaenge = GlobalGameSettings.computer_denktiefe
@onready var computerdenkt_fortschrittanzeige: ColorRect = $"/root/Main/UICanvasLayer/ZugBeenden/ComputerdenktFortschrittanzeige"
@onready var fortschrittanzeige_max_breite = computerdenkt_fortschrittanzeige.size.x
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"
var percent: float = 0.0
var word_array


func _ready() -> void:
	computerdenkt_fortschrittanzeige.visible = false
	

func draw_bar():
	var new_breite = fortschrittanzeige_max_breite * percent
		
	computerdenkt_fortschrittanzeige.size.x = new_breite
	computerdenkt_fortschrittanzeige.color.r = 1- percent
	computerdenkt_fortschrittanzeige.color.g = percent

func think():
	var erlaubte_felder = global_concepts.get_allowed_spielfelder()
	print(erlaubte_felder)
	# TODO HIER WEITER!!!
	pass

#func init_word_array():
	#word_array = []
	#var belegte_felder = global_concepts.get_belegte_felder()
	#print(belegte_felder)
	#for y in range(GlobalGameSettings.anzahl_felder):
		#var word_array_x_line = []
		#
		#for x in range(GlobalGameSettings.anzahl_felder):
		#
			#
			#var feld = [x, y]
			#if feld in belegte_felder:
				#word_array_x_line.append(belegte_felder[feld])
			#else:
				#word_array_x_line.append("")
		#word_array.append(word_array_x_line)
	#print(word_array)
	#

func _process(delta: float) -> void:
	if aktiv:
		#print("aktiv", aktiv)
			
		durchgang += 1
		percent = durchgang/max_durchgaenge
		draw_bar()
		think()
		if durchgang >= max_durchgaenge:
			print("ende computerzug")
			global_concepts.change_an_der_reihe()
		
