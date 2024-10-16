extends Area2D

@export var speed = 400

var screen_size = Vector2.ZERO
var rocket_size
enum { 
	INACTIVE,
	ACTIVE,
	FIRING
}
var rocket_state = INACTIVE

const BORDER_SIZE = 64

func _ready() -> void:
	screen_size = get_window().get_visible_rect().size
	rocket_size = $Sprite2D.texture.get_size()
	position_rocket(screen_size)


func position_rocket(_screen_size):
	position.x = screen_size.x / 2
	position.y = screen_size.y - BORDER_SIZE - (rocket_size.y * 3)


func reset_rocket():
	position.y = screen_size.y - BORDER_SIZE - (rocket_size.y * 3)
	change_state(ACTIVE)


func change_state(new_state):
	match new_state:
		INACTIVE:
			$CollisionShape2D.set_deferred("disabled", true)
		ACTIVE:
			$CollisionShape2D.set_deferred("disabled", false)
		FIRING:
			$CollisionShape2D.set_deferred("disabled", false)
	rocket_state = new_state


func _process(delta: float) -> void:
	match rocket_state:
		INACTIVE:
			return
		ACTIVE:
			if Input.is_action_just_pressed("fire"):
				$FireSFX.play()
				change_state(FIRING)
			if Input.get_axis("left", "right"):
				var direction = Input.get_axis("left", "right")
				position.x += speed * direction * delta
		FIRING:
			position.y -= speed * delta
	
	position.x = clampf(position.x, 0 + (rocket_size.x * 3) + BORDER_SIZE, screen_size.x - (rocket_size.x * 3) - BORDER_SIZE)


func _on_area_entered(area: Area2D) -> void:
	reset_rocket()
	if area.is_in_group("enemies"):
		area.hit_spaceship()
