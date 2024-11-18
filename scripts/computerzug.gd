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


func get_buchstaben():
	var buchstaben = []
	for stein_nr in global_concepts.computer.steine:
		buchstaben.append(global_concepts.computer.steine[stein_nr])
	return buchstaben

func think():
	var gelegte_woerter_mit_zelle_und_richtung = global_concepts.read_gelegte_woerter(true)
	
	var vorhandene_buchstaben = get_buchstaben()
	#print(vorhandene_buchstaben)
	print(global_concepts.wortliste)	
	for wort_lst in gelegte_woerter_mit_zelle_und_richtung:
		var wort = wort_lst[0]
		var zelle = wort_lst[1]
		var richtung = wort_lst[2]
		
		if wort in global_concepts.wortliste:
			print()
			#if wort xxx
	#
	var erlaubte_felder = global_concepts.get_allowed_spielfelder()
	print(erlaubte_felder)
	# TODO HIER WEITER!!! TESTEN IM MAIN!!!!
	pass
	#1. Wörter lesen  mit einzelbuchstaben 
	#2. Welche erlaubten wörter beinhalten die gelesenen wörter inkl. Einzelbucjstaben
	#3. Welche buchstaben bräuchte ich
	#4. Welchen platz beöuchte ich
	#5. Liste möglicher wörter vor check
	#6. Check mit word array, wörter einlesen, allesamt korrekte wörter?
	#7. Punkteliste erstellen
	#8. Bestes wort wählen

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
		
