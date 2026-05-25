extends RigidBody2D

@export_enum("FIRE", "WATER", "AIR") var jar_type: int = 0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Eklediğimiz ışığı koda tanımlıyoruz
@onready var jar_light: PointLight2D = $JarLight 

func _ready():
	add_to_group("jar")
	
	match jar_type:
		0: # FIRE
			animated_sprite.play("fire")
			jar_light.enabled = true
			jar_light.color = Color(1.0, 0.5, 0.1) # Turuncu ateş rengi
		1: # WATER
			animated_sprite.play("water")
			jar_light.enabled = false 

		2: # AIR
			animated_sprite.play("air")
			jar_light.enabled = false
			
func _process(_delta):
	if jar_type == 0 and jar_light.enabled:
		jar_light.energy = randf_range(1.0, 1.4)
