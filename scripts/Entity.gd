class_name Entity
extends Area2D

export var speed = 300
export var max_hp = 50

signal died(entity_name)
signal update_hp(curr_hp, max_hp)


var hp = 50
var anim = 'idle'
var flip = false
var heading = Vector2.ZERO
var collisions = []
var dead = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	hp = max_hp


func _process(delta):
	set_z_index(floor(self.position.y))
		


func _physics_process(delta):
	collisions = get_overlapping_areas()


func _on_Entity_damage(amount, target_name):
	if self.name != target_name:
		return

	print(self.name, ' damaged for ', amount)
	hp -= amount
	if hp <= 0:
		print('i died!')
		dead = true
		emit_signal("died", self.name)
		if not self.is_in_group('player'):
			self.queue_free()
	elif self.is_in_group('player'):
		emit_signal('update_hp', hp, max_hp)
	else:
		pass
	
