extends MarginContainer

onready var deeper_header = $VBoxContainer/CenterContainer/Deeper
onready var deeper1 = $VBoxContainer/MarginContainer1/CenterContainer/Deeper
onready var deeper2 = $VBoxContainer/MarginContainer2/CenterContainer/Deeper

var count = 0

onready var deepers = [deeper1, deeper2]
var correct_deeper = null
var incorrect_deeper = null

var diffs = [
#	"color",
	"letter",
#	"size",
#	"font",
]

func _ready():
	next(true)
	

func next(first):
	# Use correct prop as next header header
	if not first:
		var header_scene = PackedScene.new()
		header_scene.pack(correct_deeper)
		var new_header = header_scene.instance()
		var p0 = deeper_header.get_parent()
		p0.remove_child(deeper_header)
		p0.add_child(new_header)
		new_header.set_owner(p0)
		deeper_header = $VBoxContainer/CenterContainer/Deeper
		
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
	deepers = [deeper1, deeper2]
	
	# Next prop
	var deeper = random_deeper()
	if deeper == deeper1:
		correct_deeper = deeper1
		incorrect_deeper = deeper2
	else:
		correct_deeper = deeper2
		incorrect_deeper = deeper1
	
	var change_header = randi() % 2
	if change_header:
		diff(deeper_header)
		deeper_header = $VBoxContainer/CenterContainer/Deeper
		
		var scene = PackedScene.new()
		scene.pack(deeper_header)
		var new_deeper = scene.instance()
		var parent = correct_deeper.get_parent()
		parent.remove_child(correct_deeper)
		parent.add_child(new_deeper)
		new_deeper.set_owner(parent)
		
		correct_deeper = new_deeper
	else:
		diff(incorrect_deeper)
		
	deeper1 = $VBoxContainer/MarginContainer1/CenterContainer/Deeper
	deeper2 = $VBoxContainer/MarginContainer2/CenterContainer/Deeper


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


func diff(deeper):
	var diff = random_diff()
	match diff:
		"letter":
			var eff = []
			if deeper.text_length() < 9:
				eff.push_back("add")
			if deeper.text_length() > 5:
				eff.push_back("remove")
			
			var reff = eff[randi() % eff.size()]
			match reff:
				"add":
					var letter = deeper.random_letter()
					var new_letter = letter.duplicate()
					deeper.add_child(new_letter)
					var pos = letter.get_position_in_parent()
					deeper.move_child(new_letter, pos + 1)
					new_letter.set_owner(deeper)
				"remove":
					var letter = deeper.random_letter()
					deeper.remove_child(letter)
					letter.queue_free()
		_:
			print("not implemented")


func _on_MarginContainer1_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			answer(deeper1)


func _on_MarginContainer2_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			answer(deeper2)


func answer(selected_deeper):
	if selected_deeper == correct_deeper:
		print("correct!")
		next(false)
	else:
		print("failed!")
