extends Node

var aktiv = false

func _process(delta: float) -> void:
	if aktiv:
		print("computer zug aktiv")
