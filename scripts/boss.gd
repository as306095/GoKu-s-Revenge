extends Area2D

class_name Boss

#Self-explanatory
@export var max_hp: float = 320.0
var hp: float

#Don't remove this
var health_bar: ProgressBar

#Death Explosion
@onready var explosion = preload("res://scenes/effects/explosion_big.tscn")

#Leave empty for automatic detection
@export var moves: Array[String]

#Used to cancel boss logic on death
var interrupt = false

#If you add any moves to base class add them here
var not_moves = [
	"_ready",
	"logic",
	"_on_body_entered",
	"get_hit",
	"spawn_explosions"
]

func _ready():
	add_to_group("bosses")
	
	if moves.is_empty():
		var a = get_script().get_script_method_list()
		moves.clear()
		for i in a:
			if i.name not in not_moves:
				moves.append(i.name)
	print(moves)
	body_entered.connect(_on_body_entered)
	
	hp = max_hp
	if health_bar != null:
		health_bar.value = hp/max_hp
	
	logic()


enum modes {SEQUENCE, RANDOM, TRUE_RANDOM}
@export var mode = modes.RANDOM
#Handles going through the list of options the boss has
func logic():
	if moves.is_empty():
		print("BOSS LOGIC ERROR: Boss has no moves!")
		return
	match mode:
		modes.SEQUENCE:
			#Goes through all moves in order
			while not interrupt:
				for i in range(moves.size()):
					if not interrupt:
						await call(moves[i])
		modes.RANDOM:
			#Goes through all moves in random order
			while not interrupt:
				var queue = moves.duplicate()
				for i in range(queue.size()):
					if not interrupt:
						var a = queue.pick_random()
						queue.erase(a)
						await call(a)
		modes.TRUE_RANDOM:
			#Straight up picks a random move every time
			while not interrupt:
				await call(moves.pick_random())
				
				
#Hits the player if they walk into the boss
func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()

#Call this from player bullet script
func get_hit():
	if not interrupt:
		hp -= 1
		if health_bar != null:
			health_bar.value = hp/max_hp
		if hp <= 0:
			health_bar.value = 0
			interrupt = true
			await spawn_explosions()
			queue_free()
		
func spawn_explosions():
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("Godot")
	for i in range(10):
		var e = explosion.instantiate()
		e.position = Vector2(rng.randi_range(-50,50),rng.randi_range(-50,50))
		add_child(e)
		await await get_tree().create_timer(0.2 - i*0.01).timeout
