extends Item


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var heading = Vector2.ZERO
var speed = 400
var breaking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Spin")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += heading * speed * delta
	

func _physics_process(delta):
	if bodies.size() > 0 and not breaking:
		breaking = true
		emit_signal('hit', get_position(), bodies, damage)
		$Break.play()
		self.hide()
		$Timer.stop()

func _on_Timer_timeout():
	print('create splat and destroy...')
	$Break.play()
	hide()


func _on_Break_finished():
	queue_free()
