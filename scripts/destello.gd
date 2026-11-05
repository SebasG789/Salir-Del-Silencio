# ------------------------------------------------------------------
# DESTELLO DE LUZ (cuando un pensamiento es vencido)
# Luz que se expande, un anillo y chispas. Se borra sola.
# ------------------------------------------------------------------
extends Node2D

@onready var luz: PointLight2D = $Luz
@onready var particulas: CPUParticles2D = $Particulas

var radio := 2.0
var alfa := 1.0


func _ready() -> void:
	particulas.emitting = true

	var tween := create_tween().set_parallel(true)
	tween.tween_property(luz, "energy", 0.0, 0.8).from(2.6)
	tween.tween_property(luz, "texture_scale", 1.3, 0.8).from(0.3)
	tween.tween_property(self, "radio", 30.0, 0.45).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "alfa", 0.0, 0.45)
	tween.chain().tween_interval(0.4)
	tween.chain().tween_callback(queue_free)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_arc(Vector2.ZERO, radio, 0.0, TAU, 32, Color(1.0, 0.97, 0.8, alfa), 2.0)
	draw_arc(Vector2.ZERO, radio * 0.6, 0.0, TAU, 24, Color(0.7, 0.9, 1.0, alfa * 0.6), 1.0)
