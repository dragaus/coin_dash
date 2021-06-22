extends Area2D

signal pickup
signal hurt

export (int) var speed
var velocity = Vector2()
var screenSize = Vector2(480,720)

func _ready():
	pass # Replace with function body.

func get_input():
	velocity = Vector2();
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.animation = "run"
		$AnimatedSprite.flip_h = velocity.x < 0
	else :
		$AnimatedSprite.animation = "idle"

func start(pos):
	set_process(true)
	position = pos
	$AnimatedSprite.animation = "idle"
	
func die():
	$AnimatedSprite.animation = "hurt"
	set_process(false);

func _process(delta):
	get_input()
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screenSize.x)
	position.y = clamp(position.y, 0, screenSize.y)

func _on_player_area_entered(area):
	if area.is_in_group("coins"):
		area.pickup()
		emit_signal("pickup", "coin")
	if area.is_in_group("powerups"):
		area.pickup()
		emit_signal("pickup", "powerup")
	if area.is_in_group("obstacles"):
		emit_signal("hurt")
		die()
