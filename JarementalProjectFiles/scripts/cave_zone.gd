extends Area2D

# Inspector'dan GlobalLight (CanvasModulate) node'unu buraya sürükle!
@export var global_light: CanvasModulate 

var outside_color = Color(1.0, 1.0, 1.0, 1.0)
var cave_color = Color(0.4, 0.4, 0.48, 1.0)

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Ekrana yazı yazdırarak Area2D'nin çalışıp çalışmadığını test edelim
	print("Mağaraya giren obje: ", body.name)
	
	# name.to_lower() kullanarak büyük/küçük harf sorununu kökten çözüyoruz
	if body.name.to_lower() == "player":
		print("Player mağaraya girdi, ışıklar kararıyor!")
		if global_light != null:
			var tween = create_tween()
			tween.tween_property(global_light, "color", cave_color, 1.0)
		else:
			push_error("HATA: GlobalLight atanmamış! Lütfen Inspector'dan sürükleyin.")

func _on_body_exited(body):
	if body.name.to_lower() == "player":
		print("Player mağaradan çıktı, ışıklar aydınlanıyor!")
		if global_light != null:
			var tween = create_tween()
			tween.tween_property(global_light, "color", outside_color, 1.0)
