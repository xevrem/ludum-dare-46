extends Item

func _ready():
	$Animation.play('explode')

func _on_Timer_timeout():
	emit_signal('hit', get_position(), bodies, damage)
	$Boom.play()
	self.hide()


func _on_Boom_finished():
	print('finished')
	queue_free()
