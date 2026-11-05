# ------------------------------------------------------------------
# FRASES DE LOS PENSAMIENTOS
# NEGATIVAS: lo que dicen los enemigos mientras están vivos.
# POSITIVAS: lo que aparece cuando Alex los vence (la frase que los contradice).
# Para agregar frases nuevas, solo escríbelas en la lista que corresponda.
# ------------------------------------------------------------------
class_name Frases

const NEGATIVAS := {
	"voz": [
		"Nadie quiere escucharte",
		"Mejor quédate callado",
		"Van a pensar que exageras",
		"Lo que sientes no importa",
		"Si hablas, vas a molestar",
		"Nadie te va a entender",
		"Es más fácil no decir nada",
		"Tus problemas son tonterías",
	],
	"culpa": [
		"Todo es tu culpa",
		"Siempre lo arruinas",
		"No mereces sentirte mejor",
		"Deberías haberlo hecho mejor",
		"Nunca haces nada bien",
		"Todos están decepcionados de ti",
		"No tienes perdón",
	],
	"aislamiento": [
		"Estás solo",
		"A nadie le importas",
		"Es mejor alejarte de todos",
		"Nadie te va a buscar",
		"No encajas en ningún lado",
		"Mejor no molestes a nadie",
		"Nadie te extraña",
	],
	"ansiedad": [
		"¿Y si todo sale mal?",
		"No vas a poder",
		"Todos te están juzgando",
		"Algo malo va a pasar",
		"Vas a fallar otra vez",
		"Es demasiado para ti",
		"Nunca vas a salir de aquí",
	],
}

const POSITIVAS := {
	"voz": [
		"Lo que sientes importa.",
		"Tu voz merece ser escuchada.",
		"Hablar es un acto de valentía.",
		"Hay personas que quieren escucharte.",
		"Decir \"no estoy bien\" está bien.",
	],
	"culpa": [
		"Equivocarse es humano.",
		"Mereces sentirte mejor.",
		"No eres tus errores.",
		"Puedes aprender y seguir adelante.",
		"Sé amable contigo mismo.",
	],
	"aislamiento": [
		"Hay personas que quieren acompañarte.",
		"No estás solo.",
		"Pedir compañía no es molestar.",
		"Alguien se alegra de verte.",
		"Conectar con otros ayuda.",
	],
	"ansiedad": [
		"Respira. Un paso a la vez.",
		"Puedes con esto, poco a poco.",
		"No tienes que resolverlo todo hoy.",
		"Este momento también pasará.",
		"Enfócate en lo que sí puedes hacer.",
	],
}


static func negativas(tipo: String) -> Array:
	var lista: Array = NEGATIVAS.get(tipo, NEGATIVAS["voz"]).duplicate()
	lista.shuffle()
	return lista


static func positiva(tipo: String) -> String:
	var lista: Array = POSITIVAS.get(tipo, POSITIVAS["voz"])
	return lista.pick_random()
