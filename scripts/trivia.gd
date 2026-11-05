# ------------------------------------------------------------------
# TRIVIA INICIAL Y FINAL
# Antes de jugar se hace la trivia inicial (PREGUNTAS) y al salir del
# bosque la final (PREGUNTAS_FINAL): preguntas distintas sobre los mismos
# 6 temas, para comparar tema por tema qué aprendió el jugador.
# El modo lo decide Juego.modo_trivia ("inicial" o "final").
# Las opciones se muestran en orden distinto cada vez.
# Para cambiar o agregar preguntas, edita la lista PREGUNTAS.
# "correcta" es el número de la opción correcta (empieza en 0).
# ------------------------------------------------------------------
class_name Trivia
extends Control

const PREGUNTAS := [
	{
		"tema": "Qué es la depresión",
		"pregunta": "¿La depresión es lo mismo que estar triste un día?",
		"opciones": [
			"Sí, es exactamente lo mismo",
			"No: dura semanas o más y afecta el ánimo, la energía, el sueño y las ganas de hacer cosas",
			"Es solo falta de voluntad"
		],
		"correcta": 1,
		"explicacion": "Todos nos sentimos tristes a veces. La depresión es diferente: es persistente y afecta muchas áreas de la vida. No es falta de voluntad."
	},
	{
		"tema": "Señales",
		"pregunta": "¿Cuál de estas puede ser una señal de depresión?",
		"opciones": [
			"Perder el interés en cosas que antes disfrutabas",
			"Tener hambre antes del almuerzo",
			"Cansarse después de hacer deporte"
		],
		"correcta": 0,
		"explicacion": "Perder el interés o el gusto por las cosas es una señal común. Otras son cambios en el sueño, cansancio constante y sentirse sin valor o con mucha culpa."
	},
	{
		"tema": "Cómo ayudar a otro",
		"pregunta": "Si un amigo te cuenta que se siente muy mal, ¿qué es lo más útil?",
		"opciones": [
			"Decirle que no exagere",
			"Cambiar de tema para que se distraiga",
			"Escucharlo sin juzgar y animarlo a buscar apoyo"
		],
		"correcta": 2,
		"explicacion": "Escuchar con atención y sin juzgar ayuda mucho. También puedes animarlo a hablar con un adulto de confianza o con un profesional."
	},
	{
		"tema": "A quién afecta",
		"pregunta": "¿A quién puede afectar la depresión?",
		"opciones": [
			"Solo a adultos mayores",
			"A cualquier persona, de cualquier edad",
			"Solo a personas que tienen problemas muy graves"
		],
		"correcta": 1,
		"explicacion": "La depresión puede afectar a niños, jóvenes y adultos, sin importar cómo se vea su vida desde afuera."
	},
	{
		"tema": "Pedir ayuda",
		"pregunta": "Buscar ayuda de un psicólogo o un médico es...",
		"opciones": [
			"Una señal de debilidad",
			"Solo para casos extremos",
			"Una forma válida de cuidar tu salud"
		],
		"correcta": 2,
		"explicacion": "La salud mental es parte de la salud. Pedir ayuda profesional es una decisión valiente y efectiva."
	},
	{
		"tema": "Recuperación",
		"pregunta": "¿La depresión se puede tratar?",
		"opciones": [
			"Sí, con apoyo y tratamiento muchas personas mejoran",
			"No, es para siempre",
			"Se quita sola si te esfuerzas más"
		],
		"correcta": 0,
		"explicacion": "Hay tratamientos que funcionan, como la psicoterapia y, en algunos casos, medicamentos indicados por un profesional. Pedir ayuda a tiempo marca la diferencia."
	},
]

# Trivia final: preguntas DISTINTAS, pero del mismo tema y en el mismo orden,
# para poder comparar tema por tema lo que el jugador aprendió.
const PREGUNTAS_FINAL := [
	{
		"tema": "Qué es la depresión",
		"pregunta": "Alex llevaba semanas sin ganas de nada y durmiendo mal. ¿Qué podría estar viviendo?",
		"opciones": [
			"Solo es flojera, ya se le pasará",
			"Posibles señales de depresión; vale la pena hablarlo con alguien",
			"Algo normal que se quita si lo ignora"
		],
		"correcta": 1,
		"explicacion": "Cuando la tristeza, el cansancio o la falta de ganas duran semanas, pueden ser señales de depresión. Hablarlo con alguien de confianza es un buen paso."
	},
	{
		"tema": "Señales",
		"pregunta": "¿Cuál de estas NO es una señal común de depresión?",
		"opciones": [
			"Cambios fuertes en el sueño",
			"Sentirse sin valor o con mucha culpa",
			"Sentirse con mucha energía y ganas todo el tiempo"
		],
		"correcta": 2,
		"explicacion": "Las señales comunes incluyen cambios en el sueño, cansancio, perder el interés y sentirse sin valor o con culpa. Tener mucha energía y ganas no es una de ellas."
	},
	{
		"tema": "Cómo ayudar a otro",
		"pregunta": "Nico te dice que siente que nadie lo notaría si se aleja de sus amigos. ¿Qué haces?",
		"opciones": [
			"Le dices que está exagerando",
			"Te quedas, lo escuchas y le ofreces buscar juntos a alguien de confianza",
			"Te vas para darle espacio"
		],
		"correcta": 1,
		"explicacion": "Quedarse y escuchar sin juzgar ayuda mucho. Acompañar a la persona a buscar apoyo de un adulto o profesional también es una forma de cuidarla."
	},
	{
		"tema": "A quién afecta",
		"pregunta": "¿Una persona que se ve feliz en redes sociales puede tener depresión?",
		"opciones": [
			"No, se le notaría",
			"Solo si lo publica",
			"Sí, no siempre se nota desde afuera"
		],
		"correcta": 2,
		"explicacion": "La depresión no siempre se ve. Muchas personas sonríen o se ven bien por fuera mientras por dentro la están pasando mal."
	},
	{
		"tema": "Pedir ayuda",
		"pregunta": "¿Cuál es un buen primer paso para pedir ayuda?",
		"opciones": [
			"Hablar con alguien de confianza: un familiar, un docente o un profesional de salud",
			"Esperar a que se pase solo",
			"No contarle a nadie para no preocuparlos"
		],
		"correcta": 0,
		"explicacion": "Contarle a alguien de confianza es un primer paso valiente. Esa persona puede acompañarte a buscar ayuda profesional."
	},
	{
		"tema": "Recuperación",
		"pregunta": "Sobre la recuperación de la depresión, ¿qué es cierto?",
		"opciones": [
			"Si un día te sientes bien, ya estás curado",
			"Es un proceso con días buenos y días difíciles, y con apoyo se avanza",
			"Si tienes un mal día, no sirvió de nada"
		],
		"correcta": 1,
		"explicacion": "Recuperarse lleva tiempo. Tener días difíciles no significa volver al inicio: con apoyo y tratamiento se sigue avanzando."
	},
]

@onready var encabezado: Label = $Panel/Margen/VBox/Encabezado
@onready var progreso: Label = $Panel/Margen/VBox/Progreso
@onready var texto_pregunta: Label = $Panel/Margen/VBox/Pregunta
@onready var opciones: VBoxContainer = $Panel/Margen/VBox/Opciones
@onready var explicacion: Label = $Panel/Margen/VBox/Explicacion
@onready var boton_siguiente: Button = $Panel/Margen/VBox/Botones/Siguiente
@onready var boton_menu: Button = $Panel/Margen/VBox/Botones/Menu

var modo := "inicial"
var preguntas: Array = PREGUNTAS
var indice := 0
var aciertos := 0
var respuestas: Array = []
var orden: Array = []        # orden en que se muestran las opciones
var respondida := false
var terminada := false


func _ready() -> void:
	get_tree().paused = false
	modo = Juego.modo_trivia
	preguntas = PREGUNTAS_FINAL if modo == "final" else PREGUNTAS
	if modo == "final":
		encabezado.text = "TRIVIA FINAL: ¿Qué aprendiste en el bosque?"
		boton_menu.visible = false
		Audio.musica("final")
	else:
		encabezado.text = "TRIVIA INICIAL: ¿Qué sabes sobre la depresión?"
		Audio.musica("menu")
	mostrar_pregunta()


func mostrar_pregunta() -> void:
	respondida = false
	var datos: Dictionary = preguntas[indice]
	progreso.text = "Pregunta %d de %d" % [indice + 1, preguntas.size()]
	texto_pregunta.text = datos["pregunta"]
	explicacion.visible = false
	boton_siguiente.visible = false

	for hijo in opciones.get_children():
		hijo.queue_free()

	var lista: Array = datos["opciones"]
	orden = range(lista.size())
	orden.shuffle()
	for posicion in orden.size():
		var boton := Button.new()
		boton.text = lista[orden[posicion]]
		boton.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.add_theme_font_size_override("font_size", 10)
		boton.pressed.connect(_on_opcion_pressed.bind(posicion))
		opciones.add_child(boton)
	# Enfocar la primera opción nueva (las viejas aún se están borrando)
	(opciones.get_child(opciones.get_child_count() - lista.size()) as Button).grab_focus.call_deferred()


func _on_opcion_pressed(posicion: int) -> void:
	if respondida:
		return
	respondida = true
	var datos: Dictionary = preguntas[indice]
	var correcta: int = datos["correcta"]
	var elegida: int = orden[posicion]
	var acerto := elegida == correcta
	respuestas.append(acerto)

	# Colorea las opciones: verde la correcta, rojo la elegida si estaba mal
	var primera := opciones.get_child_count() - orden.size()
	for i in orden.size():
		var boton := opciones.get_child(primera + i) as Button
		boton.disabled = true
		if orden[i] == correcta:
			boton.add_theme_color_override("font_disabled_color", Color(0.5, 1.0, 0.6))
		elif i == posicion:
			boton.add_theme_color_override("font_disabled_color", Color(1.0, 0.5, 0.5))

	if acerto:
		aciertos += 1
		Audio.sonido("correcto", 0.0, false)
		explicacion.text = "¡Correcto! " + datos["explicacion"]
		explicacion.add_theme_color_override("font_color", Color(0.7, 1.0, 0.75))
	else:
		Audio.sonido("incorrecto", 0.0, false)
		explicacion.text = "No exactamente. " + datos["explicacion"]
		explicacion.add_theme_color_override("font_color", Color(1.0, 0.85, 0.7))
	explicacion.visible = true

	boton_siguiente.text = "Siguiente" if indice < preguntas.size() - 1 else "Ver resultado"
	boton_siguiente.visible = true
	boton_siguiente.grab_focus()


func _on_siguiente_pressed() -> void:
	Audio.sonido("boton")
	if terminada:
		if modo == "final":
			get_tree().change_scene_to_file("res://escenas/evaluacion.tscn")
		else:
			get_tree().change_scene_to_file("res://escenas/juego.tscn")
		return

	indice += 1
	if indice < preguntas.size():
		mostrar_pregunta()
	else:
		mostrar_resultado()


func mostrar_resultado() -> void:
	terminada = true
	for hijo in opciones.get_children():
		hijo.queue_free()
	progreso.text = "Resultado"
	texto_pregunta.text = "Acertaste %d de %d preguntas." % [aciertos, preguntas.size()]
	Juego.total_trivia = preguntas.size()

	if modo == "final":
		Juego.puntaje_final = aciertos
		Juego.respuestas_final = respuestas
		explicacion.text = "Ahora mira cómo te fue comparado con la trivia del inicio."
		boton_siguiente.text = "Ver mi progreso"
	else:
		Juego.puntaje_trivia = aciertos
		Juego.respuestas_inicial = respuestas
		if aciertos == preguntas.size():
			explicacion.text = "¡Sabes mucho sobre el tema! Ahora acompaña a Alex y mira cómo se vive desde adentro."
		elif aciertos >= 3:
			explicacion.text = "Vas por buen camino. En el bosque vas a descubrir más sobre lo que vive una persona con depresión."
		else:
			explicacion.text = "No pasa nada: para eso es este juego. Acompaña a Alex y aprende en el camino."
		boton_siguiente.text = "Comenzar la aventura"
	explicacion.remove_theme_color_override("font_color")
	explicacion.visible = true
	boton_siguiente.visible = true
	boton_siguiente.grab_focus()


func _on_menu_pressed() -> void:
	Audio.sonido("boton")
	get_tree().change_scene_to_file("res://escenas/menu_principal.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if modo == "inicial" and event.is_action_pressed("ui_cancel"):
		_on_menu_pressed()
