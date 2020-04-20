extends Entity

signal place_bomb(position)
signal toss_elixer(position, heading)
signal set_trap(position)

var can_place_bomb = true
var can_toss_elixer = true
var can_set_trap = true
var throwing = false
var setting_trap = false
var setting_bomb = false

var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		return
		
	heading = Vector2()
	
	# movement
	if not (setting_trap or setting_bomb):
		if Input.is_action_pressed("player_right"):
			heading.x = 1
		if Input.is_action_pressed("player_left"):
			heading.x = -1
		if Input.is_action_pressed("player_up"):
			heading.y = -1
		if Input.is_action_pressed("player_down"):
			heading.y = 1
		
	heading = heading.normalized()
	
	if self.heading.length() > 0 and (not (throwing or setting_trap or setting_bomb)):
		$Animation.set_animation('walk')
	elif throwing:
		$Animation.set_animation("throw")
	elif setting_trap:
		$Animation.set_animation("trap")
	elif setting_bomb:
		$Animation.set_animation('bomb')
	else:
		$Animation.set_animation('idle')
	
	if self.heading.x < 0:
		$Animation.set_flip_h(true)
	else:
		$Animation.set_flip_h(false)
	
	$Animation.play()
	
	# actions
	if Input.is_action_pressed("place_bomb"):
		if can_place_bomb:
			can_place_bomb = false
			setting_bomb = true
			$BombTimer.start()
			$bomb_fuse.play()
	elif Input.is_action_pressed("toss_elixer"):
		if can_toss_elixer:
			can_toss_elixer = false
			$ElixerTimer.start()
			throwing = true
			$elixer_throw.play()
	elif Input.is_action_pressed("set_trap"):
		if can_set_trap:
			can_set_trap = false
			$TrapTimer.start()
			setting_trap = true
			$Trap.play()
			
		
	self.position += heading * speed * delta


func _on_BombTimer_timeout():
	can_place_bomb = true


func _on_ElixerTimer_timeout():
	can_toss_elixer = true


func _on_Animation_animation_finished():
	if throwing:
		emit_signal('toss_elixer', position + Vector2(heading.x * 50,-57), heading)
		throwing = false
	if setting_trap:
		emit_signal('set_trap', position)
		setting_trap = false
	if setting_bomb:
		setting_bomb = false
		emit_signal('place_bomb', position + Vector2(50,-25))
		

func _on_TrapTimer_timeout():
	can_set_trap = true


func _on_Entity_damage(amount, target_name):
	if self.name != target_name:
		return
	
	if not $ow1.playing and not $ow2.playing:
		var which = random.randi_range(0,1)
		if which == 0:
			$ow1.play()
		else:
			$ow2.play()
		
	._on_Entity_damage(amount, target_name)
	
	
