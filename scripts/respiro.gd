# ------------------------------------------------------------------
# RESPIRO (recupera 1 de energía)
# Basado en FV_heart del Zelda.
# ------------------------------------------------------------------
class_name Respiro
extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var tomado := false


func _ready() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(sprite_2d, "scale", Vector2(1.2, 1.2), 0.7).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite_2d, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_SINE)


func _on_body_entered(body: Node2D) -> void:
	if tomado:
		return
	if body is Alex:
		tomado = true
		Audio.sonido("respiro")
		Juego.cambiar_energia(1)
		Juego.texto_flotante(global_position, "Respiras... +1 energía", Color(0.75, 0.95, 1.0))
		queue_free()
