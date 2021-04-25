extends Camera2D


var shake = false
var shake_magnitude = null
var saved_offset = null
var shake_timer = null


func start_shake(duration, magnitude):
	shake = true
	shake_magnitude = magnitude
	saved_offset = offset
	shake_timer = Timer.new()
	add_child(shake_timer)
	shake_timer.start(duration)
	shake_timer.connect("timeout", self, "_shake_timer_timeout")


func _process(_delta):
	if shake:
		offset = saved_offset
		var ofx = rand_range(-1.0, 1.0) * shake_magnitude
		var ofy = rand_range(-1.0, 1.0) * shake_magnitude
		offset += Vector2(ofx, ofy)


func _shake_timer_timeout():
	shake = false
	offset = saved_offset
