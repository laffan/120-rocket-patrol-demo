extends Node

@export var enemy_ship_scene : PackedScene
@onready var scrolling_background = $Starfield
@onready var player = $Rocket

var scroll_speed = 300
var scroll_direction = Vector2(1, 0)
var screen_size = Vector2.ZERO
enum { 
	START,
	PLAY,
	GAME_OVER
}
var game_state = START
var score = 0
var hi_score = 0
var game_time
const NUM_ENEMY_SHIPS = 3
const BORDER_SIZE = 64

func _ready() -> void:
	screen_size = get_window().get_visible_rect().size


func start_game():
	score = 0
	$HUD/UIContainer/ScoreContainer/Score.text = "SCORE: " + str(score)
	game_time = 60
	$HUD/UIContainer/TimeContainer/Time.text = "TIME: " + str(game_time)
	spawn_enemy_ships()
	$GameTimer.start()
	player.change_state(player.ACTIVE)


func _process(delta: float) -> void:
	# scroll starfield background
	scrolling_background.scroll_offset += scroll_direction * scroll_speed * delta
	
	# handle game state
	match game_state:
		START:
			if Input.is_action_just_pressed("select"):
				$UISelectSFX.play()
				change_state(PLAY)
		PLAY:
			pass
		GAME_OVER:
			if Input.is_action_just_pressed("select"):
				$UISelectSFX.play()
				change_state(START)


func change_state(new_state):
	match new_state:
		START:
			$HUD/StartUIBackground/StartMessage.text = "◅ ▻ : MOVE ▰ F/SPACE : FIRE ▰ ENTER : START GAME"
			$HUD/StartUIBackground.show()
		PLAY:
			$HUD/StartUIBackground.hide()
			start_game()
		GAME_OVER:
			$HUD/StartUIBackground/StartMessage.text = "GAME OVER ▰ HI-SCORE: " + str(hi_score) + " ▰ ENTER TO RESTART"
			$HUD/StartUIBackground.show()
			game_over()
	game_state = new_state


func spawn_enemy_ships():
	var x_pos = screen_size.x
	var y_pos = BORDER_SIZE * 4
	var ship_score = 50
	for i in NUM_ENEMY_SHIPS:
		var ship = enemy_ship_scene.instantiate()
		add_child(ship)
		ship.position_ship(x_pos, y_pos)
		ship.set_score_value(ship_score)
		x_pos += BORDER_SIZE * 4
		y_pos += BORDER_SIZE * 2
		ship_score -= 20
		ship.spaceship_hit.connect(_on_spaceship_hit)


func _on_game_timer_timeout() -> void:
	game_time -= 1
	$HUD/UIContainer/TimeContainer/Time.text = "TIME: " + str(game_time)
	if game_time <= 0:
		change_state(GAME_OVER)


func _on_spaceship_hit(score_value):
	$ExplosionSFX.play()
	score += score_value
	$HUD/UIContainer/ScoreContainer/Score.text = "SCORE: " + str(score)
	if score >= hi_score:
		hi_score = score


func game_over():
	player.change_state(player.INACTIVE)
	player.position_rocket(screen_size)
	get_tree().call_group("enemies", "queue_free")
	$GameTimer.stop()
