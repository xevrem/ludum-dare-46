extends Area2D


signal hit(collisions)
var heading = Vector2.ZERO
var speed = 500
var damage = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	$TtlTimer.start()


func set_heading(value):
	heading = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += heading * delta * speed


func _physics_process(delta):
	var collisions = get_overlapping_areas()
	if collisions.size() > 0:
		print('laser hit: ', collisions[0].name)
		emit_signal('hit', collisions, damage)
		queue_free()

func _on_TtlTimer_timeout():
#	print('destroy laser')
	queue_free()
