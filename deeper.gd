extends Control


func get_letters():
	return get_children()
	

func text_length():
	return get_child_count()


func random_letter():
	var letters = get_letters()
	return letters[randi() % letters.size()]
