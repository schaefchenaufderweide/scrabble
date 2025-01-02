extends Node

@onready var stein_scene = preload("res://scenes/Spielstein.tscn")
@onready var global_concepts: Node = $"/root/Main/GlobalConcepts"


@onready var hand_area = $HandArea
@onready var select_rect = $HandArea/SelectRect
@onready var timer = $Timer
@onready var name_edit_popup = $"/root/Main/UICanvasLayer/ButtonPlayer/LineEdit"

var steine_dict = {}
var stein_hand_positions = {}
var is_touched = false
var punkte = 0
var soll_punkte = 0
var rel_button
var rel_punkte_label
var slow_count = 0
var name_of_party


func _ready() -> void:
	
	ziehe_steine()
	if name == "Player":
		rel_punkte_label = $"/root/Main/UICanvasLayer/ButtonPlayer/Label"
		rel_button = $"/root/Main/UICanvasLayer/ButtonPlayer"
		rel_button.art = "Player Button"
		name_of_party = "Player"
		
	else:
		rel_punkte_label = $"/root/Main/UICanvasLayer/ButtonComputer/Label"
		rel_button = $"/root/Main/UICanvasLayer/ButtonComputer"
		rel_button.art = "Computer Button"
		var difficulty = int(global_concepts.difficulty_slider.value)
		name_of_party = global_concepts.difficulties_dict[difficulty]
	update_text()
	
	
func _process(_delta: float) -> void:
	if punkte < soll_punkte:
		slow_count += 1
		var slow_count_max
		if abs(soll_punkte - punkte) > 20:
			slow_count_max = 4
		elif abs(soll_punkte - punkte) > 10:
			slow_count_max = 6
		else:
			slow_count_max = 10
		#print(slow_count_max)
		if slow_count == slow_count_max:
			
			punkte += 1
			update_text()
			slow_count = 0

func update_text():
	rel_punkte_label.text = name_of_party + ": " + str(punkte)

func ziehe_steine():
	
	if not global_concepts.buchstaben_im_sackerl:
		#print("buchstaben sind aus!")
		return
	var anzahl_steine = GlobalGameSettings.anzahl_steine_pro_hand
	var abstand = GlobalGameSettings.abstand_zwischen_steinen
	
	
	for nr_stein in range(anzahl_steine):
		
		if not steine_dict.get(nr_stein):
			
			var new_stein = stein_scene.instantiate()
			new_stein.name = "Stein " + str(nr_stein)
			add_child(new_stein)  
			var erste_x = hand_area.position.x - anzahl_steine/2 * (new_stein.size.x + abstand)
			var new_pos_x = erste_x + nr_stein * (new_stein.size.x + abstand)
			var new_pos_y = hand_area.position.y
			#print(new_stein.size)
			new_stein.position.x = randi_range(0, global_concepts.screen_size.x)
			new_stein.position.y = global_concepts.screen_size.y + 100
			var tween = create_tween()
			
			tween.tween_property(new_stein, "position", Vector2(new_pos_x, new_pos_y), 0.5)
			#new_stein.position.x = new_pos_x
			#new_stein.position.y = hand_area.position.y
			new_stein.pos_in_hand = nr_stein
			var random_buchstabe_nr = randi_range(0, len(global_concepts.buchstaben_im_sackerl) - 1)
			var new_buchstabe = global_concepts.buchstaben_im_sackerl.pop_at(random_buchstabe_nr)
			
			
			new_stein.label_buchstabe.text = new_buchstabe
			new_stein.label_wert.text = str(GlobalGameSettings.spielsteine_start[new_buchstabe]["Wert"])
			steine_dict[nr_stein] = new_stein
			
			stein_hand_positions[new_stein] = Vector2(new_pos_x, new_pos_y)
			new_stein.wert = GlobalGameSettings.spielsteine_start[new_buchstabe]["Wert"]
			if self == global_concepts.computer:
				new_stein.visible = false
	#print(self, get_buchstaben())

func get_buchstaben():
	var buchstaben = []
	for stein_nr in steine_dict:
		if steine_dict[stein_nr]:  # nicht leer
			buchstaben.append(steine_dict[stein_nr].label_buchstabe.text)
	return buchstaben

func get_markierte_steine():
	var markierte_steine = []
	for stein_nr in steine_dict:
		if not steine_dict[stein_nr]:
			continue
		if steine_dict[stein_nr].eintauschen_sprite.visible:
			markierte_steine.append(stein_nr)
			
			
	
	return markierte_steine
		
func _on_hand_area_mouse_entered() -> void:
	#print("hand")
	is_touched = true
	if global_concepts.spielstein_is_dragged:
		select_rect.visible = true
		

func _on_hand_area_mouse_exited() -> void:
	select_rect.visible = false
	is_touched = false
	if global_concepts.spielstein_is_dragged:
		timer.stop()
		#print("timer stopped")
		


func _on_timer_timeout() -> void:
	#print("timer ended")
	zum_tausch_markieren()
	
func check_markieren():
	if not global_concepts.buchstaben_im_sackerl:
		return
	if not get_markierte_steine():
		timer.start()
		#print("Timer start")
	else:
		#print("fast markieren")
		zum_tausch_markieren()
		
func zum_tausch_markieren():
	if global_concepts.spielstein_is_dragged:
		var frisch_belegt = global_concepts.get_belegte_felder(true)
		if not frisch_belegt:
			global_concepts.dragged_stein.zum_tausch_markieren()
		
			global_concepts.change_zug_beenden_label(frisch_belegt)
			
func steine_tauschen():
	var markierte_steine = get_markierte_steine()
	
	for stein_nr in markierte_steine:
		
		var buchstabe = steine_dict[stein_nr].label_buchstabe.text
		global_concepts.buchstaben_im_sackerl.append(buchstabe)
		
		# hinaus
		var new_pos_x = steine_dict[stein_nr].position.x
		var new_pos_y = global_concepts.screen_size.y + 100
		var tween = create_tween()
		tween.tween_property(steine_dict[stein_nr], "position", Vector2(new_pos_x, new_pos_y), 0.5)
		steine_dict[stein_nr] = null
	global_concepts.buchstaben_im_sackerl.shuffle()
	
	
	
func add_punkte(new_punkte):
	soll_punkte += new_punkte
	
