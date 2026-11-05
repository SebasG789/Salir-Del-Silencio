# ------------------------------------------------------------------
# AUDIO (Autoload)
# Música de fondo con cambio suave entre canciones y efectos de sonido.
# Uso:
#   Audio.musica("bosque")      -> cambia la canción
#   Audio.sonido("espada")      -> reproduce un efecto
# Música: Ninja Adventure de Pixel-boy (licencia CC0).
# Efectos: generados para este juego.
# ------------------------------------------------------------------
extends Node

const MUSICAS := {
	"menu": "res://assets/musica/menu.ogg",
	"bosque": "res://assets/musica/bosque.ogg",
	"tension": "res://assets/musica/tension.ogg",
	"final": "res://assets/musica/final.ogg",
}

const SONIDOS := {
	"espada": "res://assets/sonidos/espada.wav",
	"golpe": "res://assets/sonidos/golpe.wav",
	"enemigo_vencido": "res://assets/sonidos/enemigo_vencido.wav",
	"aparece": "res://assets/sonidos/aparece.wav",
	"danio": "res://assets/sonidos/danio.wav",
	"respiro": "res://assets/sonidos/respiro.wav",
	"fragmento": "res://assets/sonidos/fragmento.wav",
	"dialogo": "res://assets/sonidos/dialogo.wav",
	"boton": "res://assets/sonidos/boton.wav",
	"puerta_cerrada": "res://assets/sonidos/puerta_cerrada.wav",
	"correcto": "res://assets/sonidos/correcto.wav",
	"incorrecto": "res://assets/sonidos/incorrecto.wav",
	"salida": "res://assets/sonidos/salida.wav",
}

const VOLUMEN_MUSICA := -10.0
const SILENCIO := -40.0

var reproductor_a := AudioStreamPlayer.new()
var reproductor_b := AudioStreamPlayer.new()
var efectos: Array[AudioStreamPlayer] = []
var cancion_actual := ""
var cache := {}
var musica_activada := true


func _ready() -> void:
	# Suena aunque el juego esté en pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(reproductor_a)
	add_child(reproductor_b)
	for i in 8:
		var efecto := AudioStreamPlayer.new()
		add_child(efecto)
		efectos.append(efecto)


func cargar(ruta: String) -> AudioStream:
	if not cache.has(ruta):
		cache[ruta] = load(ruta)
	return cache[ruta]


# ----------------------------------
# MUSICA
# ----------------------------------
func musica(nombre: String, duracion_fundido: float = 1.5) -> void:
	if nombre == cancion_actual or not MUSICAS.has(nombre):
		return
	cancion_actual = nombre

	var stream := cargar(MUSICAS[nombre])
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true

	# El que está sonando se apaga y el otro empieza la nueva canción
	var saliente := reproductor_a if reproductor_a.playing else reproductor_b
	var entrante := reproductor_b if saliente == reproductor_a else reproductor_a

	entrante.stream = stream
	entrante.volume_db = SILENCIO
	entrante.play()

	var tween := create_tween().set_parallel(true)
	tween.tween_property(entrante, "volume_db", VOLUMEN_MUSICA if musica_activada else SILENCIO, duracion_fundido)
	if saliente.playing:
		tween.tween_property(saliente, "volume_db", SILENCIO, duracion_fundido)
		tween.chain().tween_callback(saliente.stop)


func alternar_musica() -> void:
	musica_activada = not musica_activada
	for r in [reproductor_a, reproductor_b]:
		if r.playing:
			r.volume_db = VOLUMEN_MUSICA if musica_activada else SILENCIO


# ----------------------------------
# EFECTOS DE SONIDO
# ----------------------------------
func sonido(nombre: String, volumen_db: float = 0.0, variar_tono: bool = true) -> void:
	if not SONIDOS.has(nombre):
		return
	var libre: AudioStreamPlayer = null
	for efecto in efectos:
		if not efecto.playing:
			libre = efecto
			break
	if libre == null:
		libre = efectos[0]
	libre.stream = cargar(SONIDOS[nombre])
	libre.volume_db = volumen_db
	libre.pitch_scale = randf_range(0.94, 1.06) if variar_tono else 1.0
	libre.play()
