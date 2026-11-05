# ------------------------------------------------------------------
# ZONA DEL BOSQUE
# Muestra el nombre de la zona al entrar. Si es un lugar seguro,
# Alex recupera su energía y ese lugar queda como punto de reaparición.
# ------------------------------------------------------------------
class_name Zona
extends Area2D

@export var nombre := "Zona"
@export var subtitulo := ""
@export var es_lugar_seguro := false
@export var punto_reaparicion := Vector2.ZERO
# Canción de la zona: "bosque" o "tension"
@export_enum("bosque", "tension") var musica: String = "bosque"


func _on_body_entered(body: Node2D) -> void:
	if not (body is Alex):
		return

	if Juego.zona_actual != nombre:
		Juego.zona_actual = nombre
		Audio.musica(musica)
		Juego.hud.mostrar_zona(nombre, subtitulo)

	if es_lugar_seguro:
		Juego.punto_reaparicion = punto_reaparicion
		if Juego.energia < Juego.ENERGIA_MAXIMA:
			Juego.recuperar_energia()
			Juego.texto_flotante(body.global_position, "Aquí puedes descansar", Color(0.7, 0.9, 1.0))
