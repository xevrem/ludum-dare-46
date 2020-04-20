extends Item


var snapping = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bodies.size() > 0 and not snapping:
		snapping = true
		emit_signal("hit", get_position(), bodies, damage)
		$Snap.play()
		hide()


func _on_Snap_finished():
	queue_free()
