# ------------------------------------------------------------------
# TU PROGRESO
# Al terminar la trivia final, el jugador ve su resultado de la trivia
# inicial comparado con la final, tema por tema. No se guarda nada.
# ------------------------------------------------------------------
extends Control

@onready var contenido: VBoxContainer = $Panel/Margen/VBox/Scroll/Contenido
@onready var boton_menu: Button = $Panel/Margen/VBox/Botones/Menu


func _ready() -> void:
	get_tree().paused = false
	Audio.musica("final")
	construir_progreso()
	boton_menu.grab_focus.call_deferred()


func etiqueta(texto: String, tamano: int = 9, color: Color = Color(0.92, 0.94, 1), centrado: bool = false) -> Label:
	var l := Label.new()
	l.text = texto
	if centrado:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", tamano)
	l.add_theme_color_override("font_color", color)
	contenido.add_child(l)
	return l


func construir_progreso() -> void:
	var inicial := Juego.puntaje_trivia
	var fin := Juego.puntaje_final
	var total := Juego.total_trivia

	etiqueta("TU PROGRESO", 14, Color(1, 0.88, 0.6), true)

	if inicial < 0:
		etiqueta("Trivia final: %d de %d" % [fin, total], 12, Color.WHITE, true)
		etiqueta("No hiciste la trivia inicial, así que no hay con qué comparar.", 9, Color(0.92, 0.94, 1), true)
		return

	etiqueta("Trivia inicial: %d de %d   >>   Trivia final: %d de %d" % [inicial, total, fin, total], 12, Color.WHITE, true)

	var mensaje := ""
	if fin > inicial:
		mensaje = "¡Mejoraste %d respuesta(s)! El recorrido de Alex te dejó aprendizajes." % (fin - inicial)
	elif fin == inicial and fin == total:
		mensaje = "Mantuviste todas las respuestas correctas. ¡Ya sabías mucho del tema!"
	elif fin == inicial:
		mensaje = "Obtuviste el mismo resultado. Revisa las explicaciones: cada pregunta tiene algo para aprender."
	else:
		mensaje = "Esta vez fallaste algunas más. Las explicaciones de cada pregunta te pueden ayudar."
	etiqueta(mensaje, 10, Color(0.75, 0.95, 0.8), true)

	contenido.add_child(HSeparator.new())
	etiqueta("Resultado por tema", 10, Color(1, 0.9, 0.7), true)

	# Detalle tema por tema
	var preguntas: Array = Trivia.PREGUNTAS
	for i in preguntas.size():
		var antes := texto_resultado(Juego.respuestas_inicial, i)
		var despues := texto_resultado(Juego.respuestas_final, i)
		var color := Color(0.85, 0.88, 1)
		var nota := ""
		if antes == "mal" and despues == "bien":
			color = Color(0.6, 1, 0.65)
			nota = "  (¡aprendiste!)"
		elif antes == "bien" and despues == "mal":
			color = Color(1, 0.7, 0.6)
		etiqueta("%d. %s   Inicial: %s  ·  Final: %s%s" % [i + 1, preguntas[i]["tema"], antes, despues, nota], 10, color)

	contenido.add_child(HSeparator.new())
	etiqueta("Recuerda: tu salud mental importa. Hablar de lo que sientes y buscar ayuda puede ser el primer paso.", 9, Color(0.75, 0.9, 1), true)


func texto_resultado(lista: Array, i: int) -> String:
	if i >= lista.size():
		return "-"
	return "bien" if lista[i] else "mal"


func _on_menu_pressed() -> void:
	Audio.sonido("boton")
	get_tree().change_scene_to_file("res://escenas/menu_principal.tscn")
