extends Node

signal damage_player(amount)
signal damage_enemies(amount)
signal update_score(amount)
signal confuse_enemy(name)

onready var player = get_node('Player')
onready var zombieScene = load("res://scenes/Zombie.tscn")
onready var robotScene = load("res://scenes/Robot.tscn")
onready var bombScene = load("res://scenes/Bomb.tscn")
onready var elixerScene = load("res:///scenes/Elixer.tscn")
onready var trapScene = load("res:///scenes/Trap.tscn")
onready var explosionScene = load("res://scenes/Explosion.tscn")
onready var laserScene = load("res://scenes/Laser.tscn")

var score = 0
var size = null
var random = RandomNumberGenerator.new()
var next_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	size = get_viewport().size
	
	self.connect('update_score', $Score, '_on_update_score')
	
	self.connect('damage_player', player, '_on_Entity_damage')
	player.connect('update_hp', $HitPoints, '_on_update_hp')
	player.connect('place_bomb', self, '_on_Player_place_bomb')
	player.connect('died', self, '_on_Player_death')
	player.connect('toss_elixer', self, '_on_Player_toss_elixer')
	player.connect('set_trap', self, '_on_Player_set_trap')
	
	create_zombie()
	create_robot()

func get_start_position():
	var where = random.randi_range(0,3)
	if where == 0:
		return Vector2(0, size.y * random.randf())
	elif where == 1:
		return Vector2(size.x, size.y * random.randf())
	elif where == 2:
		return Vector2(size.x * random.randf(), 0)
	else:
		return Vector2(size.x * random.randf(), size.y)
	

	
func create_zombie():
	var zombie = zombieScene.instance()
	zombie.set_target(player)
	zombie.set_position(get_start_position())		
	
	zombie.connect('attack', self, '_on_Zombie_attack')
	zombie.connect('died', self, '_on_Zombie_death')
	connect('damage_enemies', zombie, '_on_Entity_damage')
	connect('confuse_enemy', zombie, '_on_Elixer_confuse')
	add_child(zombie)


func create_robot():
	var robot = robotScene.instance()
	robot.set_target(player)
	robot.set_position(get_start_position())
	robot.connect('attack', self, '_on_Robot_attack')
	robot.connect('died', self, '_on_Robot_death')
	connect('damage_enemies', robot, '_on_Entity_damage')
	connect('confuse_enemy', robot, '_on_Elixer_confuse')
	add_child(robot)

func create_explosion(position):
	var explosion = explosionScene.instance()
	explosion.set_position(position)
	add_child(explosion)
	pass


func _on_Player_place_bomb(position):
#	print('place bomb...')
	var bomb = bombScene.instance()
	bomb.set_position(position - Vector2(0,1))
	bomb.connect('hit', self, '_on_Bomb_hit')
	add_child(bomb)


func _on_Player_toss_elixer(position, heading):
	if heading.length() > 0:
#		print('tossing elixer...')
		var elixer = elixerScene.instance()
		elixer.heading = heading
		elixer.set_position(position)
		elixer.connect('hit', self, '_on_Elixer_hit')
		add_child(elixer)


func _on_Player_set_trap(position):
	var trap = trapScene.instance()
	trap.position = position
	trap.connect('hit', self, '_on_Trap_hit')
	add_child(trap)


func _on_Player_death(player_name):
	for enemy in get_tree().get_nodes_in_group('enemies'):
		enemy.queue_free()
	for item in get_tree().get_nodes_in_group('items'):
		item.queue_free()
	size = get_viewport().size
	player.hp = player.max_hp
	player.dead = false
	emit_signal("update_score", 0)
	$HitPoints._on_update_hp(player.hp, player.max_hp)
	player.set_position(Vector2(size.x/2, size.y/2))



func _on_Bomb_hit(position, bodies, damage):
#	print('i hit:', bodies)
	for entity in bodies:
		if entity.is_in_group('enemies'):
			emit_signal('damage_enemies', damage, entity.name)
	
	create_explosion(position)


func _on_Elixer_hit(position, bodies, damage):
	var enemy = bodies.pop_front()
	for target in get_tree().get_nodes_in_group("enemies"):
		if target.name == enemy.name:
			continue
		else:
			emit_signal('confuse_enemy', enemy.name, target)
			return
			
func _on_Trap_hit(position, bodies, damage):
	var enemy = bodies.pop_front()
	print('trap hit: ', enemy.name)
	emit_signal('damage_enemies', damage, enemy.name)


func _on_Zombie_attack(target, damage):
	if target.name == player.name:
		emit_signal('damage_player', damage, player.name)
	else:
		emit_signal('damage_enemies', damage, target.name)


func _on_Zombie_death(zombie):
	print('zombie dead!')
	score += 5
	emit_signal("update_score", score)


func _on_ZombieTimer_timeout():
#	print('creating zombie...')
	create_zombie()


func _on_Robot_attack(target, robot_position):
	var laser = laserScene.instance()
	laser.set_heading(robot_position.direction_to(target.position))
	laser.set_position(robot_position + laser.heading * 50 + Vector2(0,-50))
	laser.set_rotation(robot_position.angle_to_point(target.position))
	laser.connect('hit', self, '_on_Laser_hit')
	add_child(laser)
#	print('robot attacks!')


func _on_Robot_death(robot):
	print('robot dead!')
	score += 10
	emit_signal("update_score", score)

	
func _on_RobotTimer_timeout():
#	print('creating robot...')
	create_robot()


func _on_Laser_hit(collisions, damage):
	if collisions.has(player):
		emit_signal("damage_player", damage, player.name)
	else:
		emit_signal('damage_enemies', damage, collisions[0].name)
