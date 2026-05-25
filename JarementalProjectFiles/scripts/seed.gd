extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var watered: bool = false

func _ready():
	add_to_group("seed")
	animated_sprite.play("seed")  # Başlangıç animasyonu

func water_given() -> void:
	if watered:
		return
	watered = true
	
	var tween = create_tween()
	animated_sprite.scale = Vector2(0.1, 0.1)
	tween.tween_property(animated_sprite, "scale", Vector2(1.0, 1.0), 0.5)\
		 .set_ease(Tween.EASE_OUT)\
		 .set_trans(Tween.TRANS_ELASTIC)
	
	await tween.finished
	animated_sprite.play("plant")

# Collision'ı bitki boyutuna göre ayarla
	var shape = collision.shape as RectangleShape2D
	shape.size = Vector2(16, 48)  # Bitki boyutuna göre ayarla
