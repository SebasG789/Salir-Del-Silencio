# ------------------------------------------------------------------
# NPC (personaje con el que se puede hablar)
# Lía (Inicio), Rosa (Santuario) y Sam (El Apoyo).
# Muestran un "!" cuando tienen algo nuevo que decir, miran a Alex
# cuando se acerca y tienen respuestas para elegir.
# ------------------------------------------------------------------
class_name NPC
extends StaticBody2D

@export var nombre := "Lía"
@export_enum("lia", "rosa", "sam", "nico", "vale") var personaje: String = "lia"
@export var textura: Texture2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var burbuja: Sprite2D = $Burbuja

var jugador: Alex = null
var mostrando_pista := false
var hablando := false
var veces_hablado := 0


func _ready() -> void:
	add_to_group("interactuables")
	if textura != null:
		sprite_2d.texture = textura
	jugador = get_tree().get_first_node_in_group("jugador") as Alex
	if personaje == "sam":
		Juego.registrar_lugar("Sam", global_position)
	elif personaje == "nico":
		Juego.registrar_lugar("Nico", global_position)
	elif personaje == "vale":
		Juego.registrar_lugar("Vale", global_position)

	# El "!" sube y baja
	var tween := create_tween().set_loops()
	tween.tween_property(burbuja, "position:y", -22.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(burbuja, "position:y", -19.0, 0.5).set_trans(Tween.TRANS_SINE)
	actualizar_burbuja()


func _process(_delta: float) -> void:
	if jugador == null or Juego.hud == null or hablando:
		return
	var distancia := global_position.distance_to(jugador.global_position)

	# Mira hacia Alex cuando está cerca
	if distancia < 80:
		mirar_hacia(jugador.global_position)

	var cerca := distancia < 42
	if cerca and not mostrando_pista:
		mostrando_pista = true
		Juego.hud.mostrar_pista("E: hablar con " + nombre)
	elif not cerca and mostrando_pista:
		mostrando_pista = false
		Juego.hud.ocultar_pista()


func mirar_hacia(objetivo: Vector2) -> void:
	var d := objetivo - global_position
	# En la hoja de sprites cada columna es una dirección: abajo, arriba, izquierda, derecha
	var columna := 0
	if abs(d.x) > abs(d.y):
		columna = 3 if d.x > 0 else 2
	elif d.y < 0:
		columna = 1
	sprite_2d.frame = columna


func actualizar_burbuja() -> void:
	if personaje == "sam":
		burbuja.visible = not Juego.acepto_apoyo
	elif personaje == "nico":
		burbuja.visible = not Juego.ayudo_a_nico
	elif personaje == "vale":
		burbuja.visible = not Juego.ayudo_a_vale
	else:
		burbuja.visible = veces_hablado == 0


# ----------------------------------
# CONVERSACION
# ----------------------------------
func interactuar() -> void:
	if hablando:
		return
	hablando = true
	mostrando_pista = false
	Juego.hud.ocultar_pista()

	match personaje:
		"lia":
			await hablar_lia()
		"rosa":
			await hablar_rosa()
		"sam":
			await hablar_sam()
		"nico":
			await hablar_nico()
		"vale":
			await hablar_vale()

	veces_hablado += 1
	actualizar_burbuja()
	hablando = false


func decir(lineas: Array) -> void:
	await Juego.hud.mostrar_dialogo(nombre, PackedStringArray(lineas))


func preguntar(texto: String, opciones: Array) -> int:
	return await Juego.hud.mostrar_opciones(nombre, texto, PackedStringArray(opciones))


# Lía: la guía del inicio
func hablar_lia() -> void:
	if veces_hablado == 0:
		await decir([
			"¡Alex! Por fin despiertas.",
			"Soy Lía. Yo también me perdí en este bosque hace un tiempo."
		])
		var respuesta := await preguntar("¿Cómo te sientes?", ["Bien, supongo", "No lo sé...", "Prefiero no hablar"])
		match respuesta:
			0:
				await decir(["Me alegra. Igual, si algo te pesa, puedes contármelo."])
			1:
				await decir(["Está bien no saberlo. A veces los sentimientos se enredan como esta niebla."])
			2:
				await decir(["Lo respeto. Cuando quieras hablar, aquí voy a estar."])
		await decir([
			"Las sombras de este bosque repiten cosas feas. No son la verdad: son pensamientos.",
			"Enfréntalas con tu espada de luz (ESPACIO).",
			"Busca tres fragmentos: La Voz, El Apoyo y La Esperanza. Sigue la flecha dorada.",
			"Si te pierdes, presiona M para ver el mapa."
		])
	else:
		var respuesta := await preguntar("¿Necesitas algo?", ["¿A dónde voy?", "¿Cómo recupero vida?", "Nada, gracias"])
		match respuesta:
			0:
				await decir([Juego.objetivo_texto + "."])
			1:
				await decir(["Recoge las luces de respiro, o descansa en un lugar seguro: el Inicio, el Santuario o El Apoyo."])
			2:
				await decir(["¡Ánimo, Alex!"])


# Rosa: la sabia del Santuario
func hablar_rosa() -> void:
	if veces_hablado == 0:
		await decir([
			"Bienvenido al Santuario, Alex.",
			"Aquí nadie te juzga. Puedes descansar todo lo que necesites."
		])
	while true:
		var respuesta := await preguntar("¿Qué quieres saber?", [
			"¿Qué es la depresión?",
			"¿Por qué hay sombras?",
			"¿Hacia dónde sigo?",
			"Adiós"
		])
		match respuesta:
			0:
				await decir([
					"No es solo estar triste. Es cuando la tristeza, el cansancio o el vacío duran semanas y cuesta hacer las cosas de siempre.",
					"No es culpa de nadie, y se puede tratar con apoyo de personas de confianza y de profesionales."
				])
			1:
				await decir([
					"Las sombras son pensamientos negativos. Gritan fuerte, pero no dicen la verdad.",
					"Cuando las enfrentas, debajo aparece algo más amable."
				])
			2:
				await decir([
					"Sam está en El Apoyo: cruza el puente del este.",
					"Abajo, en El Aislamiento, hay un chico llamado Nico que lleva mucho tiempo solo. Ve a verlo.",
					"La Esperanza está al sureste. Y la salida, al noreste del bosque."
				])
			_:
				await decir(["Vuelve cuando quieras."])
				return


# Sam: aceptar compañía
func hablar_sam() -> void:
	if Juego.acepto_apoyo:
		await decir(["Sigue adelante, Alex. No estás solo.", "Y recuerda: pedir ayuda no te hace débil."])
		return

	if veces_hablado == 0:
		await decir([
			"Hola... te vi caminando solo por el bosque.",
			"No tienes que contarme todo ahora."
		])
	else:
		await decir(["Volviste. Me alegra verte."])

	var respuesta := await preguntar("¿Quieres sentarte un rato conmigo?", ["Sí, gracias", "Prefiero seguir solo"])
	if respuesta == 0:
		await decir([
			"Me alegra que te quedes.",
			"Cuando quieras hablar, te escucho. Y si pesa demasiado, podemos buscar ayuda juntos.",
			"(Algo empieza a brillar junto a la fogata...)"
		])
		Juego.acepto_apoyo = true
		Juego.activar_fragmento("El Apoyo")
		Juego.actualizar_objetivo()
	else:
		await decir([
			"Está bien. Pero si cambias de opinión, aquí estaré.",
			"Aceptar compañía también es valiente."
		])


# Nico: está solo en la niebla de El Aislamiento. Hablar con él es obligatorio:
# La Esperanza solo aparece cuando Alex se queda a acompañarlo.
func hablar_nico() -> void:
	if Juego.ayudo_a_nico:
		await decir(["Gracias por quedarte, Alex.", "Sigue adelante: La Esperanza te espera al sureste."])
		return

	if veces_hablado == 0:
		await decir([
			"(Un chico está sentado solo entre la niebla. Casi no se le ve.)",
			"...¿Me hablas a mí? Aquí nunca viene nadie."
		])
	else:
		await decir(["(Nico sigue ahí, en silencio.)", "...Volviste."])

	var respuesta := await preguntar("¿Qué le dices?", [
		"Te vi solo y quise saludarte",
		"¿Estás bien?",
		"Perdón, solo voy de paso"
	])
	if respuesta == 2:
		await decir([
			"Sí... todos van de paso.",
			"(Nico baja la mirada. Tal vez necesitaba que alguien se quedara un momento.)"
		])
		return

	await decir([
		"...Hace mucho que nadie me preguntaba algo así.",
		"A veces siento que si dejo de hablarle a mis amigos, nadie lo notaría."
	])
	var apoyo := await preguntar("¿Qué le respondes?", [
		"Yo sí lo notaría",
		"Eso lo dicen las sombras, no es la verdad",
		"Podemos buscar a alguien de confianza juntos"
	])
	match apoyo:
		0:
			await decir(["...Gracias. No sabía cuánto necesitaba escuchar eso."])
		1:
			await decir(["Tienes razón... las sombras gritan fuerte. Pero no son yo."])
		2:
			await decir(["Sí... hablar con alguien me puede ayudar. No tengo que hacerlo solo."])

	await decir([
		"(Nico se levanta. La niebla a su alrededor se aclara un poco.)",
		"Mira, allá al sureste, en el pedestal de La Esperanza, acaba de encenderse una luz.",
		"A veces acompañar a alguien también nos ayuda a nosotros."
	])
	Juego.ayudo_a_nico = true
	Juego.activar_fragmento("La Esperanza")
	Juego.actualizar_objetivo()


# Vale: está atrapada en La Ansiedad. Alex le enseña a respirar
# (inhalar 4, sostener 4, exhalar 4) y ella le devuelve la calma: vida completa.
func hablar_vale() -> void:
	if Juego.ayudo_a_vale:
		await decir(["Sigo practicando: inhalo 4, sostengo 4, exhalo 4.", "Gracias por detenerte conmigo, Alex."])
		return

	if veces_hablado == 0:
		await decir([
			"(Una chica camina de un lado a otro, muy rápido. Respira agitada.)",
			"¡No, no, no! ¿Y si me pierdo? ¿Y si nunca salgo de aquí? ¿Y si todo sale mal?"
		])
	else:
		await decir(["(Vale sigue caminando en círculos.)", "...¿Otra vez tú?"])

	var respuesta := await preguntar("¿Qué haces?", [
		"Tranquila, estoy aquí contigo",
		"¿Quieres respirar conmigo un momento?",
		"Lo siento, tengo prisa"
	])
	if respuesta == 2:
		await decir([
			"...Claro. Todos tienen prisa.",
			"(Vale sigue caminando. Sus pensamientos suenan cada vez más fuerte.)"
		])
		return

	await decir([
		"...Gracias por detenerte.",
		"Mi cabeza no para. Siento que algo malo va a pasar, aunque no sé qué."
	])
	await decir([
		"(Alex se sienta a su lado y le propone respirar juntos.)",
		"Inhala despacio... 1, 2, 3, 4.",
		"Sostén el aire... 1, 2, 3, 4.",
		"Ahora suelta todo despacio... 1, 2, 3, 4.",
		"(Lo repiten tres veces.)"
	])
	var siguiente := await preguntar("¿Qué más le dices?", [
		"Mira a tu alrededor: dime tres cosas que ves",
		"Lo que sientes es real, pero va a pasar",
		"Si vuelve, puedes contárselo a alguien de confianza"
	])
	match siguiente:
		0:
			await decir(["Veo... una piedra, un farol y a ti.", "...Cuando miro lo que hay aquí, el ruido baja."])
		1:
			await decir(["Sí... la ansiedad se siente enorme, pero no dura para siempre."])
		2:
			await decir(["Tienes razón. No tengo que aguantarlo sola."])

	await decir([
		"Ya me siento un poco mejor. Las arañas no se ven tan grandes.",
		"Ten, respira tú también: cuando todo te rodee, un paso a la vez."
	])
	if Juego.tiene_todos():
		await decir(["Y Alex... la salida ya no se ve tan lejos. Ahora sí puedes dar ese paso."])
	else:
		await decir(["Cuando tengas los fragmentos, recuerda: para salir también hace falta calma."])
	Juego.ayudo_a_vale = true
	Juego.actualizar_objetivo()
	Juego.recuperar_energia()
	Juego.texto_flotante(jugador.global_position, "Respiras con calma: vida completa", Color(0.75, 0.95, 1.0))
	Audio.sonido("respiro", 0.0, false)
