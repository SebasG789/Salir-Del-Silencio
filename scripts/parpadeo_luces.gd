# ------------------------------------------------------------------
# PARPADEO DE LOS FAROLES
# Cada luz hija cambia un poco su intensidad, como una llama.
# ------------------------------------------------------------------
extends Node2D

var energias := {}
var fases := {}


func _ready() -> void:
	for hijo in get_children():
		var luz := hijo as PointLight2D
		if luz != null:
			energias[luz] = luz.energy
			fases[luz] = randf() * TAU


func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for luz in energias:
		var fase: float = fases[luz]
		var variacion := 0.08 * sin(t * 7.0 + fase) + 0.05 * sin(t * 13.0 + fase * 2.0)
		luz.energy = energias[luz] * (1.0 + variacion)
