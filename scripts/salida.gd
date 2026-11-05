# ------------------------------------------------------------------
# SALIDA DEL BOSQUE
# Solo se abre con los 3 fragmentos.
# ------------------------------------------------------------------
class_name Salida
extends Area2D

@onready var luz: PointLight2D = $Luz

var saliendo := false


func _ready() -> void:
	Juego.registrar_lugar("Salida", global_position)
	Juego.fragmentos_cambio.connect(actualizar_luz)
	actualizar_luz(Juego.fragmentos)


# La luz de la puerta crece con cada fragmento
func actualizar_luz(lista: Array) -> void:
	var tween := create_tween()
	tween.tween_property(luz, "energy", 0.3 + 0.45 * lista.size(), 1.0)


func _on_body_entered(body: Node2D) -> void:
	if saliendo or not (body is Alex):
		return

	var alex := body as Alex
	alex.puede_moverse = false

	if Juego.puede_salir():
		saliendo = true
		Audio.sonido("salida", 0.0, false)
		Juego.terminar_partida()
		await Juego.hud.fundido(Color(1, 0.96, 0.85, 1), 1.5)
		get_tree().change_scene_to_file("res://escenas/final.tscn")
		return

	Audio.sonido("puerta_cerrada")
	# Tiene los fragmentos pero aún no encontró la calma
	if Juego.tiene_todos():
		await Juego.hud.mostrar_dialogo("La salida", PackedStringArray([
			"Los fragmentos brillan, pero tu corazón late muy rápido.",
			"Necesitas calmarte antes de dar este paso. Busca a Vale en La Ansiedad."
		]))
		alex.global_position += Vector2(0, 20)
		alex.puede_moverse = true
		return

	var faltan := Juego.TOTAL_FRAGMENTOS - Juego.fragmentos.size()
	await Juego.hud.mostrar_dialogo("La salida", PackedStringArray([
		"La puerta está cubierta por la niebla.",
		"Te faltan %d fragmento(s). Sigue buscando." % faltan
	]))
	alex.global_position += Vector2(0, 20)
	alex.puede_moverse = true
