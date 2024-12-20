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

var spezialfelder = {"dreifacher Wortwert": [[0,0], [7,0], [14, 0], [0, 7], [14,7], [0, 14], [7,14], [14,14]],
					"doppelter Wortwert": [[1,1],[2,2], [3,3], [4,4], [10, 4], [11, 3], [12,2], [13,1],[1, 13], [2,12], [3,11], [4,10], [10,10], [11,11], [12,12], [13,13]],
					"dreifacher Buchstabenwert": [[5,1], [9,1], [1,5], [5,5], [9,5], [13,5], [1, 9], [5,9], [9,9],[13,9], [5,13], [9,13]],
					"doppelter Buchstabenwert": [[3,0], [11,0], [0,3],[6,2],[8,2],[7,3],[2,6],[6,6],[8,6],[12,6],[3,7],[11,7],[2,8],[6,8],[8,8],[12,8],[0,11],[7,11],[14,11],[6,12],[8,12],[3,14],[11,14]],
					"Mitte": [[7,7]]}

var computer_tausch_schwelle_wert = 5
#var computer_denktiefe = 100
#var allowed_letters = spielsteine_start.keys()
