class_name Item
extends Area2D

signal hit(bodies)
export var damage = 10
var bodies = []
var destroyed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print(name, get_collision_mask())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_z_index(floor(self.position.y))
	
	if destroyed:
		self.queue_free()

func _physics_process(delta):
	bodies = get_overlapping_areas()
