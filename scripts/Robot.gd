extends Entity

signal attack(target, damage)

export var base_damage = 5
var attacking = false
var target = null
var can_attack = true
var is_idle = false

## Called when the node enters the scene tree for the first time.
func _ready():
	$Confusion.set_emitting(false)
	$Animation.set_animation('walk')
	$Arrival.play()

func set_target(entity):
	target = entity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_instance_valid(target):
		attacking = false
		$Animation.set_animation('idle')
		$Animation.play()
		return
	
	var head = Vector2.ZERO

	if not attacking and not is_idle:
		head = target.get_position() - get_position()
		self.heading = head.normalized()
		self.position += heading * speed * delta
#	else:
#		print('attacking or idle')
	
	if self.heading.x < 0:
		$Animation.set_flip_h(true)
	else:
		$Animation.set_flip_h(false)
#
	if close_enough():
		if can_attack:
#			print('robot attacks')
			can_attack = false
			attacking = true
			$AttackTimer.start()
			$Animation.set_animation('attack')
			$Attack.play()
		else:
			if not attacking:
				$Animation.set_animation('walk')
		
	$Animation.play()

func close_enough():
	if position.distance_to(target.position) < 300:
		return true
	else:
		return false


func _on_Animation_animation_finished():
	if attacking:
#		print('attack done')
		emit_signal('attack', target, position)
		is_idle = true
		$Animation.set_animation('idle')
		attacking = false
		$IdleTimer.start()


func _on_Elixer_confuse(entity_name, new_target):
	if name == entity_name:
		target = new_target
		$Confusion.set_emitting(true)
		$ConfusionTimer.start()


func _on_ConfusionTimer_timeout():
	target = get_tree().get_nodes_in_group('player')[0]
	$Confusion.set_emitting(false)


func _on_AttackTimer_timeout():
#	print('can attack again')
	can_attack = true


func _on_IdleTimer_timeout():
#	print('can move again')
	is_idle = false
	$Animation.set_animation('walk')
