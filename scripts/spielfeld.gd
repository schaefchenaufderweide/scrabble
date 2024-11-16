extends Area2D




@onready var size = $Sprite2D.texture.get_width() * scale
@onready var dreifacher_wortwert = $DreifacherWortwert
@onready var doppelter_wortwert = $DoppelterWortwert
@onready var dreifacher_buchstabenwert = $DreifacherBuchstabenwert
@onready var doppelter_buchstabenwert = $DoppelterBuchstabenwert
@onready var mitte = $Mitte

var belegt = null
var allowed = false
@onready var select_rect = $SelectRect
@onready var animation_player  = $AnimationPlayer
var feld
var frisch_belegt


func _on_mouse_entered() -> void:
	
	if GlobalConcepts.spielstein_is_dragged and allowed:
		
		select_rect.visible = true
		animation_player.play("select")
		GlobalConcepts.snap_field = self
		

	


func _on_mouse_exited() -> void:
	select_rect.visible = false
	if GlobalConcepts.snap_field == self:
		GlobalConcepts.snap_field = null
		
