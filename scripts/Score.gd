extends Label


func _on_update_score(score):
	print('update score...')
	text = "Score: %s" % score
