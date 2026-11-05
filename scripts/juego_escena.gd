# ------------------------------------------------------------------
# ESCENA PRINCIPAL DEL JUEGO
# ------------------------------------------------------------------
extends Node2D


func _ready() -> void:
	Juego.reiniciar()
	Audio.musica("bosque")
	# Esperamos a que todo esté listo y mostramos la introducción
	await get_tree().create_timer(0.8).timeout
	await Juego.hud.mostrar_dialogo("Salir del silencio", PackedStringArray([
		"Alex abre los ojos en un bosque oscuro, cubierto de niebla.",
		"No recuerda cuándo dejó de hablar con los demás... solo que el silencio se volvió pesado.",
		"Tiene un farol y una espada de luz. Su luz es pequeña, pero es suya.",
		"Cerca hay alguien esperándolo. Acércate y presiona E para hablar."
	]))

