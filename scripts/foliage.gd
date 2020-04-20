class_name Foliage
extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _process(delta):
	set_z_index(floor(self.position.y))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
