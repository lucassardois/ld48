extends MarginContainer

onready var camera = $Camera2D
onready var deeper_header = $VBoxContainer/MarginContainer/CenterContainer/Deeper
onready var deeper1 = $VBoxContainer/MarginContainer1/CenterContainer/Deeper
onready var deeper2 = $VBoxContainer/MarginContainer2/CenterContainer/Deeper
onready var or2 = $VBoxContainer/RichTextLabelOr2
onready var deeper3 = $VBoxContainer/MarginContainer3/CenterContainer/Deeper
onready var label_score = $VBoxContainer/RichTextLabelScore

var score = 0

onready var deepers = [deeper1, deeper2]
var correct_deeper = null
var incorrect_deeper = null

var diffs = [
	"letter",
	"case",
	"color",
	"font",
	"alpha",
	"rotate"
]



func _ready():
	randomize()
	next(true)
	

func next(start):
	var deeper3_visible = deeper3.get_parent().get_parent().visible
	
	if score == 10 - 1 and not deeper3_visible:
		or2.visible = true
		deeper3.get_parent().get_parent().visible = true
		deeper3_visible = true
	
	# Use correct prop as next header
	if not start:
		var header_scene = PackedScene.new()
		header_scene.pack(correct_deeper)
		var new_header = header_scene.instance()
		var p0 = deeper_header.get_parent()
		p0.remove_child(deeper_header)
		p0.add_child(new_header)
		new_header.set_owner(p0)
		deeper_header = $VBoxContainer/MarginContainer/CenterContainer/Deeper
		
	# Replace all props with the default header
	var header_scene = PackedScene.new()
	header_scene.pack(deeper_header)
	
	var new_deeper1 = header_scene.instance()
	var p1 = deeper1.get_parent()
	p1.remove_child(deeper1)
	p1.add_child(new_deeper1)
	new_deeper1.set_owner(p1)
	
	var new_deeper2 = header_scene.instance()
	var p2 = deeper2.get_parent()
	p2.remove_child(deeper2)
	p2.add_child(new_deeper2)
	new_deeper2.set_owner(p2)
	deeper1 = $VBoxContainer/MarginContainer1/CenterContainer/Deeper
	deeper2 = $VBoxContainer/MarginContainer2/CenterContainer/Deeper
	
	if deeper3_visible:
		var new_deeper3 = header_scene.instance()
		var p3 = deeper3.get_parent()
		p3.remove_child(deeper3)
		p3.add_child(new_deeper3)
		new_deeper3.set_owner(p3)
		deeper3 = $VBoxContainer/MarginContainer3/CenterContainer/Deeper
		deepers = [deeper1, deeper2, deeper3]
	else:
		deepers = [deeper1, deeper2]
	
	# Next
	var deeper = random_deeper()
	if deeper == deeper1:
		correct_deeper = deeper1
		incorrect_deeper = [deeper2, deeper3]
	elif deeper == deeper2:
		correct_deeper = deeper2
		incorrect_deeper = [deeper1, deeper3]
	else:
		correct_deeper = deeper3
		incorrect_deeper = [deeper1, deeper2]
	
	var change_header = randi() % 2
	if change_header:
		diff(deeper_header)
		deeper_header = $VBoxContainer/MarginContainer/CenterContainer/Deeper
		
		var scene = PackedScene.new()
		scene.pack(deeper_header)
		var new_deeper = scene.instance()
		var parent = correct_deeper.get_parent()
		parent.remove_child(correct_deeper)
		parent.add_child(new_deeper)
		new_deeper.set_owner(parent)
		
		correct_deeper = new_deeper
		if incorrect_deeper.size() > 1:
			var rid = incorrect_deeper[randi() % incorrect_deeper.size()]
			diff(rid)
	else:
		for d in incorrect_deeper:
			diff(d)
		
	deeper1 = $VBoxContainer/MarginContainer1/CenterContainer/Deeper
	deeper2 = $VBoxContainer/MarginContainer2/CenterContainer/Deeper
	
	if deeper3_visible:
		deeper3 = $VBoxContainer/MarginContainer3/CenterContainer/Deeper
	
	if not start:
		score = score + 1
		label_score.clear()
		label_score.push_align(RichTextLabel.ALIGN_CENTER)
		label_score.add_text("~ " + String(score) + " ~")
		label_score.play_animation()


func _input(event):
	if event.is_action_pressed("debug_restart"):
		var err = get_tree().reload_current_scene()
		if err:
			print("ERROR NUMBER " + err)
	if event.is_action_pressed("debug_quit"):
		get_tree().quit()


func random_deeper():
	return deepers[randi() % deepers.size()]
	

func random_diff():
	return diffs[randi() % diffs.size()]


func random_letter():
	var letters = ["D", "d", "E", "e", "E", "e", "P", "p", "E", "e", "R", "r"]
	return letters[randi() % letters.size()]
	

func random_color():
	var colors = [
		Color("#ff8bb8"),
		Color("#dc3839"),
		Color("#fa8b22"),
		Color("#f7de0f"),
		Color("#9cc841"),
		Color("#019db6"),
		Color("#5d4486"),
		Color.black
	]
	return colors[randi() % colors.size()]


func random_font_path():
	var font_paths = [
		"res://assets/Wobbly font.ttf",
		"res://assets/friendlyscribbles.ttf",
		"res://assets/BadComic-Regular.ttf",
		"res://assets/Kurland.ttf",
	]
	return font_paths[randi() % font_paths.size()]


func random_alpha():
	var alphas = [0.3, 0.6, 1]
	return alphas[randi() % alphas.size()]


func random_rotation():
	var rotations = [-50, -25, 0, 25, 50]
	return rotations[randi() % rotations.size()]


func diff(deeper):
	var diff = random_diff()
	match diff:
		"letter":
			var eff = []
			if deeper.text_length() < 8:
				eff.push_back("add")
			if deeper.text_length() > 5:
				eff.push_back("remove")
			
			var reff = eff[randi() % eff.size()]
			match reff:
				"add":
					var letter = deeper.random_letter()
					var new_letter = letter.duplicate()
					new_letter.get_child(0).text = random_letter()
					deeper.add_child(new_letter)
					var pos = letter.get_position_in_parent()
					deeper.move_child(new_letter, pos + 1)
					new_letter.set_owner(deeper)
					new_letter.get_child(0).set_owner(deeper)
				"remove":
					var letter = deeper.random_letter()
					deeper.remove_child(letter)
					letter.queue_free()
		"case":
			var letter = deeper.random_letter().get_child(0)
			var case = letter.text
			if case == case.to_upper():
				letter.text = case.to_lower()
			else:
				letter.text = case.to_upper()
		"color":
			var letter = deeper.random_letter().get_child(0)
			var current_color = letter.get("custom_colors/font_color")
			var color = random_color()
			while current_color == color:
				color = random_color()
			letter.add_color_override("font_color", color)
		"font":
			var letter = deeper.random_letter().get_child(0)
			var current_color = letter.get("custom_colors/font_color")
			var current_font = letter.get("custom_fonts/font")
			var current_font_path = current_font.font_data
			
			var font_path = load(random_font_path())
			while font_path == current_font_path:
				font_path = load(random_font_path())
				
			var dynfont = DynamicFont.new()
			dynfont.font_data = font_path
			dynfont.size = 70
			letter.add_font_override("font", dynfont)
			letter.add_color_override("font_color", current_color)
		"alpha":
			var letter = deeper.random_letter().get_child(0)
			var current_color = letter.get("custom_colors/font_color")
			
			var new_alpha = random_alpha()
			while abs(new_alpha - current_color.a) < 0.2:
				new_alpha = random_alpha()
			
			current_color.a = new_alpha
			letter.add_color_override("font_color", current_color)
		"rotate":
			var letter = deeper.random_letter().get_child(0)
			var new_rotation = random_rotation()
			if new_rotation == letter.rect_rotation:
				new_rotation = random_rotation()
				
			letter.rect_pivot_offset = letter.rect_size / 2
			letter.rect_rotation = new_rotation
		_:
			print("not implemented")


func _on_deeper1_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			answer(deeper1)


func _on_deeper2_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			answer(deeper2)


func _on_deeper3_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			answer(deeper3)


func answer(selected_deeper):
	if selected_deeper == correct_deeper:
		next(false)
	else:
		camera.start_shake(0.25, 4)
