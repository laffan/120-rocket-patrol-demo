extends Area2D

signal spaceship_hit

@export var ship_speed = 550
@export var explosion_scene : PackedScene

var screen_size = Vector2.ZERO
var ship_size
var score_value


func _ready() -> void:
	screen_size = get_window().get_visible_rect().size
	ship_size = $Sprite2D.get_rect().size
	ship_size.x *= 3
	ship_size.y *= 3


func position_ship(x, y):
	position.x = x
	position.y = y
	

func set_score_value(value):
	score_value = value


func _process(delta: float) -> void:
	# move spaceship
	position.x -= ship_speed * delta	
	# screen wrap x-position
	position.x = wrapf(position.x, 0 - ship_size.x * 2, screen_size.x + ship_size.x * 2)


func hit_spaceship():
	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.position = position
	position_ship(screen_size.x + randi_range(128, 256), position.y)
	spaceship_hit.emit(score_value)
