extends Area2D

var direction: int = 1
var speed: float = 0.0       # Başlangıç hızı (yavaş)
var max_speed: float = 350.0  # Maksimum hız
var acceleration: float = 300.0  # İvme miktarı
var active: bool = false

func _ready():
	# HEM Area'ları HEM DE Body'leri dinlememiz gerekiyor
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered) # <-- EKLENDİ
	
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)
	$AnimatedSprite2D.play("fireball")
	
	$CollisionShape2D.disabled = true
	await get_tree().create_timer(0.15).timeout
	$CollisionShape2D.disabled = false
	active = true

func _physics_process(delta: float) -> void:
	# İvmelenerek hızlan
	speed = min(speed + acceleration * delta, max_speed)
	position.x += speed * direction * delta
	$AnimatedSprite2D.scale.x = -direction

# 1. DURUM: Başka bir Area2D'ye çarparsa (Örn: Düşmanların Hitbox'ı)
func _on_area_entered(area: Area2D) -> void:
	if not active:
		return
	var parent = area.get_parent()
	if parent != null and parent.is_in_group("enemy"):
		if parent.has_method("die"):
			parent.die()
		queue_free()

# 2. DURUM: Bir PhysicsBody'ye çarparsa (Örn: StaticBody2D Barikat veya Duvar)
func _on_body_entered(body: Node2D) -> void:
	if not active:
		return
		
	# Barikatın ana node'u StaticBody2D olduğu için 'parent' aramıyoruz, direkt 'body'e bakıyoruz
	if body.is_in_group("burnable"):
		if body.has_method("burn"):
			body.burn()
		queue_free()
	
	# (İsteğe bağlı) Ateş topu normal bir duvara veya zemine çarptığında da yok olsun istersen:
	# elif not body.is_in_group("player"): 
	#     queue_free()

func _on_screen_exited() -> void:
	queue_free()
