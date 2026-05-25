extends CharacterBody2D

enum CharacterType { NONE, FIRE, WATER, AIR }

@export_group("Scenes")
@export var jar_scene: PackedScene  # Inspector'dan jar_pickup.tscn'i ata
@export var fireball_scene: PackedScene

@export_group("Settings")
@export var pickup_distance: float = 20.0
@export var water_ability_range: float = 80.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var drop_cast: RayCast2D = $DropCast
@onready var fire_light: PointLight2D = $FireLight

var current_character: CharacterType = CharacterType.NONE
var collected_jars: Array[CharacterType] = [] # Sadece sahip olunan kavanozlar

const STATS = {
	CharacterType.NONE: {
		"speed": 90.0,
		"jump": -200.0,
		"prefix": "default"  # Kavanoz yok animasyonu
	},
	CharacterType.FIRE: {
		"speed": 70.0,
		"jump": -183.3,
		"prefix": "fire"
	},
	CharacterType.WATER: {
		"speed": 60.0,
		"jump": -150.0,
		"prefix": "water"
	},
	CharacterType.AIR: {
		"speed": 100.0,
		"jump": -250.0,
		"prefix": "air"
	}
}

const COOLDOWNS = {
	CharacterType.NONE:  0.0,
	CharacterType.FIRE:  1.0,
	CharacterType.WATER: 1.0,
	CharacterType.AIR:   1.0
}

# Hareket ve Yetenek Değişkenleri
var SPEED: float = 90.0
var JUMP_VELOCITY: float = 0.0
var anim_prefix: String = "default"
var ability_cooldown: float = 0.0

# Dash (Hava Yeteneği) Değişkenleri
const DASH_SPEED: float = 100.0
const DASH_DURATION: float = 0.2
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: int = 1

func _ready() -> void:
	switch_character(CharacterType.NONE)

func _physics_process(delta: float) -> void:
	# Cooldown güncellemeleri
	if ability_cooldown > 0:
		ability_cooldown -= delta

	# Dash durumu aktifse sadece dash hareketini uygula
	if is_dashing:
		_process_dash(delta)
		return

	# Yerçekimi
	if not is_on_floor():
		velocity += get_gravity() * delta

	_handle_inputs()
	_handle_movement()
	_handle_animations()

	move_and_slide()

# --- INPUT (GİRDİ) YÖNETİMİ ---
func _handle_inputs() -> void:
	# Zıplama
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# E tuşu → Al veya Bırak
	if Input.is_action_just_pressed("interact"):
		if current_character == CharacterType.NONE:
			_try_pickup_jar()
		else:
			_drop_jar()

	# Karakter Değiştirme
	if Input.is_action_just_pressed("char_fire") and collected_jars.has(CharacterType.FIRE):
		switch_character(CharacterType.FIRE)
	elif Input.is_action_just_pressed("char_water") and collected_jars.has(CharacterType.WATER):
		switch_character(CharacterType.WATER)
	elif Input.is_action_just_pressed("char_air") and collected_jars.has(CharacterType.AIR):
		switch_character(CharacterType.AIR)

	# Yetenek Kullanımı
	if Input.is_action_just_pressed("ability"):
		use_ability()

# --- HAREKET VE ANİMASYON ---
func _handle_movement() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _handle_animations() -> void:
	if is_on_floor():
		if velocity.x == 0:
			animated_sprite.play(anim_prefix + "_idle")
		else:
			animated_sprite.play(anim_prefix + "_run")
	else:
		animated_sprite.play(anim_prefix + "_jump")

# --- KAVANOZ (ETKİLEŞİM) SİSTEMİ ---
func _get_nearby_jar() -> Node2D:
	var jars = get_tree().get_nodes_in_group("jar")
	for jar in jars:
		if global_position.distance_to(jar.global_position) < pickup_distance:
			return jar
	return null

func _try_pickup_jar() -> void:
	var jar = _get_nearby_jar()
	if jar:
		var new_type: CharacterType = (jar.jar_type + 1) as CharacterType
		if not collected_jars.has(new_type):
			collected_jars.append(new_type) # Envantere ekle
			
		switch_character(new_type)
		jar.queue_free()

func _drop_jar() -> void:
	if jar_scene == null:
		push_error("Jar scene atanmadı!")
		return
	
	var jar = jar_scene.instantiate()
	jar.jar_type = current_character - 1
	
	# Karakterin baktığı yön
	var drop_dir = -1 if animated_sprite.flip_h else 1
	
	# Işını biraz daha ileri uzatıyoruz (Örn: 25 piksel) ki öndeki engelleri rahat görsün
	drop_cast.target_position = Vector2(25 * drop_dir, 0)
	drop_cast.force_raycast_update() 
	
	# Eğer önümüzde bir DUVAR veya başka bir KAVANOZ varsa:
	if drop_cast.is_colliding():
		var hit_point = drop_cast.get_collision_point()
		
		# Objenin kendi genişliğini hesaba katarak (Örn: 10-12 piksel) kendimize doğru çekiyoruz.
		# Böylece ne duvarın içine girer ne de diğer kavanozun içine doğup fırlatılır.
		jar.global_position = hit_point - Vector2(12 * drop_dir, 0)
	else:
		# Önümüz tamamen boşsa güvenli bir mesafeye bırak
		jar.global_position = global_position + Vector2(16 * drop_dir, 0)
	
	get_parent().add_child(jar)
	
	# Envanter ve karakter değişimi işlemleri
	collected_jars.erase(current_character)
	switch_character(CharacterType.NONE)

func switch_character(type: CharacterType) -> void:
	current_character = type
	SPEED = STATS[type]["speed"]
	JUMP_VELOCITY = STATS[type]["jump"]
	anim_prefix = STATS[type]["prefix"]
	ability_cooldown = 0.0
	
	# Sadece ateş karakterinde ışık açık
	fire_light.enabled = (type == CharacterType.FIRE)
	
	
func _process(_delta: float) -> void:
	# Sadece karakter ATEŞ modundaysa ve ışığı açıksa titret
	if current_character == CharacterType.FIRE and fire_light.enabled:
		# 1.0 ile 1.5 arasında rastgele bir parlaklık değeri ver
		fire_light.energy = randf_range(1.2, 1.4)
# Dışarıdan tetiklenmek için (eğer lazımsa)

func collect_jar(type: CharacterType) -> void:
	if not collected_jars.has(type):
		collected_jars.append(type)
	switch_character(type)

# --- YETENEKLER ---
func use_ability() -> void:
	if ability_cooldown > 0 or current_character == CharacterType.NONE:
		return

	match current_character:
		CharacterType.FIRE:  ability_fire()
		CharacterType.WATER: ability_water()
		CharacterType.AIR:   ability_air()

	ability_cooldown = COOLDOWNS[current_character]

func ability_fire() -> void:
	if fireball_scene == null:
		return
	var fb = fireball_scene.instantiate()
	fb.direction = -1 if animated_sprite.flip_h else 1
	fb.global_position = global_position + Vector2(8 * fb.direction, 0)
	get_parent().add_child(fb)

func ability_water() -> void:
	var seeds = get_tree().get_nodes_in_group("seed")
	for s in seeds:
		if global_position.distance_to(s.global_position) < water_ability_range:
			s.water_given()
			break

func ability_air() -> void:
	if is_dashing:
		return
		
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_direction = -1 if animated_sprite.flip_h else 1
	
	# 1. Karakterin kavanozları (Layer 3) görmesini engelle
	set_collision_mask_value(3, false)
	
	# 2. Kavanozların (veya düşmanların) karakteri (Layer 2) görmesini engelle
	set_collision_layer_value(2, false)

func _process_dash(delta: float) -> void:
	dash_timer -= delta
	velocity.x = DASH_SPEED * dash_direction
	velocity.y = 0  # Dash sırasında düşme yok
	
	move_and_slide()
	
	# Dash süresi bittiğinde
	if dash_timer <= 0:
		is_dashing = false
		
		# Dash bitince çarpışmaları geri aç (Normale dön)
		set_collision_mask_value(3, true)
		set_collision_layer_value(2, true)
	
	move_and_slide()
	
	# Dash süresi bittiğinde
	if dash_timer <= 0:
		is_dashing = false
		set_collision_mask_value(3, true) # Kapattığımız 3. maskeyi geri açıyoruz
