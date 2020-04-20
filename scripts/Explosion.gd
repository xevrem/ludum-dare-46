extends Node2D


func _ready():
	$Animation.play("asplosion")

func _on_Animation_animation_finished(anim_name):
	self.queue_free()
