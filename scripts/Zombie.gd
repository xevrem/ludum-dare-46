extends Entity

signal attack(target, damage)

export var base_damage = 10
var attacking = false
var atk_elapsed = 0
var atk_rate = 1.0
var target = null

## Called when the node enters the scene tree for the first time.
func _ready():
	$Confusion.set_emitting(false)
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
	
	if not attacking:
		head = target.get_position() - get_position()
		self.heading = head.normalized()
		self.position += heading * speed * delta
	
	if self.heading.x < 0:
		$Animation.set_flip_h(true)
	else:
		$Animation.set_flip_h(false)

	if collisions.has(target):
		$Animation.set_animation('attack')
		attacking = true
	else:
		$Animation.set_animation('walk')
		attacking = false	
		
	$Animation.play()


func _on_Animation_animation_finished():
	if attacking:
		$Attack.play()
		emit_signal('attack', target, base_damage)


func _on_Elixer_confuse(entity_name, new_target):
	if name == entity_name:
		target = new_target
		$Confusion.set_emitting(true)
		$ConfusionTimer.start()


func _on_ConfusionTimer_timeout():
	target = get_tree().get_nodes_in_group('player')[0]
	$Confusion.set_emitting(false)
