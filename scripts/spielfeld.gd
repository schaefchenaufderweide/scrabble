extends Area2D




@onready var size = $Sprite2D.texture.get_width() * scale
@onready var dreifacher_wortwert = $DreifacherWortwert
@onready var doppelter_wortwert = $DoppelterWortwert
@onready var dreifacher_buchstabenwert = $DreifacherBuchstabenwert
@onready var doppelter_buchstabenwert = $DoppelterBuchstabenwert
@onready var mitte = $Mitte
@onready var global_concepts: Node =  $"/root/Main/GlobalConcepts"

var spielstein_auf_feld = null
var allowed = false
@onready var select_rect = $SelectRect
@onready var animation_player  = $AnimationPlayer
@onready var punkte_label = $PunkteLabel
@onready var punkte_label_timer = $PunkteLabel/Timer

var feld
var frisch_belegt




func _on_mouse_entered() -> void:
	#print(feld, position)
	if global_concepts.spielstein_is_dragged and not global_concepts.player.is_touched:# and allowed:
		
		select_rect.visible = true
		
		global_concepts.snap_field = self
		

	


func _on_mouse_exited() -> void:
	select_rect.visible = false
	if global_concepts.snap_field == self:
		global_concepts.snap_field = null
		




func _on_timer_timeout() -> void:
	punkte_label.visible = false
	global_concepts.punkte_tweens.erase(feld)
	
	pass # Replace with function body.
