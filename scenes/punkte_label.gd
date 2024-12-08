extends Label

@onready var timer = $Timer



func _on_timer_timeout() -> void:
	#print("verschwindibus")
	queue_free()
	
