extends Area2D

@onready var size = $Sprite2D.texture.get_width() * scale
@onready var dreifacher_wortwert = $DreifacherWortwert
@onready var doppelter_wortwert = $DoppelterWortwert
@onready var dreifacher_buchstabenwert = $DreifacherBuchstabenwert
@onready var doppelter_buchstabenwert = $DoppelterBuchstabenwert
@onready var mitte = $Mitte
