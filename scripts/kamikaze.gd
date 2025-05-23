extends Area2D

var dir = Vector2(0.0,0.0)
var plr: Node

@onready var explosion = preload("res://scenes/effects/explosion_small.tscn")

func _ready():
	add_to_group("enemies")
	plr = get_tree().get_nodes_in_group("player")[0]
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta: float) -> void:
	position += dir * delta
	var d = plr.position - position + Vector2(0,-10)
	d = d.normalized() * 500
	dir = dir.lerp(d, delta)
	
func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()
		var e = explosion.instantiate()
		e.position = position
		get_tree().root.add_child(e)
		queue_free()
		
#Call this from player bullet script
func get_hit():
	var e = explosion.instantiate()
	e.position = position
	get_tree().root.add_child(e)
	queue_free()
