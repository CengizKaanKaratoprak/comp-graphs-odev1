extends StaticBody2D

# Ateş topu bu objeye çarptığında bu fonksiyonu çağıracak
func burn() -> void:
	# İleride buraya yanma animasyonu veya duman efekti (GPUParticles2D) ekleyebilirsin.
	# Şimdilik objeyi direkt yok ediyoruz:
	queue_free()
