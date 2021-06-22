extends Node2D

export (PackedScene) var Coin
export (PackedScene) var Powerup
export (int) var playtime

var level
var score
var time_left
var screensize
var playing = false

func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$player.screenSize = screensize
	$Background.rect_size = screensize
	$player.hide()

func _process(delta):
	if playing and $CoinContainer.get_child_count() == 0:
		level += 1
		time_left += 5
		spawn_coins()

func new_game():
	playing = true
	level = 1
	score = 0
	time_left = playtime
	$player.start($PlayerStart.position)
	$player.show()
	$GameTimer.start()
	$HUD.update_score(score)
	$HUD.update_timer(time_left)
	spawn_coins()
	

func spawn_coins():
	$LevelSound.play()
	$PowerupTimer.wait_time = rand_range(5, 10)
	$PowerupTimer.start()
	for _i in range(4+level):
		var c = Coin.instance()
		$CoinContainer.add_child(c)
#		c.screensize = screensize
		c.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y))

func _on_PowerupTimer_timeout():
	var p = Powerup.instance()
	$PowerupContainer.add_child(p)
	p.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y))

func _on_GameTimer_timeout():
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()

func _on_player_pickup(type):
	match type:
		"coin":
			score += 1
			$HUD.update_score(score)
			$CoinSound.play()
		"powerup":
			time_left += 5
			$HUD.update_timer(time_left)
			$PowerupSound.play()

func _on_player_hurt():
	game_over()

func _on_coin_area_entered(area):
	if area.is_in_group("obstacles"):
		position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y))

func _on_Powerup_area_entered(area):
	if area.is_in_group("obstacles"):
		position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y))

func game_over():
	playing = false
	$GameTimer.stop()
	$PowerupTimer.stop()
	for coin in $CoinContainer.get_children():
		coin.queue_free()
	for power in $PowerupContainer.get_children():
		power.queue_free();
	$HUD.show_game_over()
	$player.die()
	$EndSound.play()
