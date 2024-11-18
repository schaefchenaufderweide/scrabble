extends Node

var anzahl_steine_pro_hand = 7
var abstand_zwischen_steinen = 5
var anzahl_felder = 15
var spielsteine_start = {"E": {"Anzahl": 15, "Wert": 1}, 
						"N": {"Anzahl": 9, "Wert": 1}, 
						"S": {"Anzahl": 7, "Wert": 1}, 
						"I": {"Anzahl": 6, "Wert": 1}, 
						"R": {"Anzahl": 6, "Wert": 1}, 
						"T": {"Anzahl": 6, "Wert": 1},
						"U": {"Anzahl": 6, "Wert": 1}, 
						"A": {"Anzahl": 5, "Wert": 1}, 
						"D": {"Anzahl": 4, "Wert": 1},
						"H": {"Anzahl": 4, "Wert": 2},
						"G": {"Anzahl": 3, "Wert": 2},
						"L": {"Anzahl": 3, "Wert": 2},
						"O": {"Anzahl": 3, "Wert": 2},
						"M": {"Anzahl": 4, "Wert": 3},
						"B": {"Anzahl": 2, "Wert": 3},
						"W": {"Anzahl": 1, "Wert": 3},
						"Z": {"Anzahl": 1, "Wert": 3},
						"C": {"Anzahl": 2, "Wert": 4},
						"F": {"Anzahl": 2, "Wert": 4},
						"K": {"Anzahl": 2, "Wert": 4},
						"P": {"Anzahl": 1, "Wert": 4},
						"Ä": {"Anzahl": 1, "Wert": 6},
						"J": {"Anzahl": 1, "Wert": 6},
						"Ü": {"Anzahl": 1, "Wert": 6},
						"V": {"Anzahl": 1, "Wert": 6},
						"Ö": {"Anzahl": 1, "Wert": 8},
						"X": {"Anzahl": 2, "Wert": 8},
						"Q": {"Anzahl": 1, "Wert": 10},
						"Y": {"Anzahl": 1, "Wert": 10},
						"?": {"Anzahl": 2, "Wert": 0}}

var computer_denktiefe = 100
