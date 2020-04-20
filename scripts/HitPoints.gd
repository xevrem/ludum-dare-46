extends Label


func _on_update_hp(curr_hp, max_hp):
	if curr_hp > 0:
		text =  "HP: %s / %s" % [curr_hp, max_hp]
	else:
		text = 'You Have Died'	
