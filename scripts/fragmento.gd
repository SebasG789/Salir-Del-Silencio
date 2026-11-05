# ------------------------------------------------------------------
# FRAGMENTO (La Voz, El Apoyo, La Esperanza)
# Basado en fv_key del Zelda. Al recogerlo muestra su mensaje.
# ------------------------------------------------------------------
class_name Fragmento
extends Area2D

const COLORES := [Color(0.75, 0.5, 1.0), Color(0.45, 0.75, 1.0), Color(1.0, 0.8, 0.3)]

@export var nombre := "La Voz"
@export_range(0, 2) var indice := 0
@export var lineas := PackedStringArray()
# El fragmento de El Apoyo aparece solo después de hablar con Sam
@export var oculto_al_inicio := false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var luz: PointLight2D = $Luz

var recogido := false


func _ready() -> void:
	Juego.registrar_lugar(nombre, global_position)
	Juego.fragmentos_en_mapa[nombre] = self
	add_to_group("fragmentos")
	sprite_2d.region_rect = Rect2(indice * 12, 0, 12, 16)
	luz.color = COLORES[indice]

	# Flota suavemente
	var tween := create_tween().set_loops()
	tween.tween_property(sprite_2d, "position:y", -10.0, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite_2d, "position:y", -6.0, 0.8).set_trans(Tween.TRANS_SINE)

	if oculto_al_inicio:
		visible = false
		monitoring = false


func activar() -> void:
	visible = true
	Audio.sonido("respiro", 0.0, false)
	set_deferred("monitoring", true)
	scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_body_entered(body: Node2D) -> void:
	if recogido or not visible:
		return
	if body is Alex:
		recoger()


func recoger() -> void:
	recogido = true
	set_deferred("monitoring", false)
	visible = false
	Audio.sonido("fragmento", 0.0, false)
	Juego.agregar_fragmento(nombre)

	await Juego.hud.mostrar_dialogo("Fragmento: " + nombre, lineas)

	if Juego.tiene_todos():
		await Juego.hud.mostrar_dialogo("Los tres fragmentos", PackedStringArray([
			"La Voz, El Apoyo y La Esperanza brillan juntos.",
			"Al noreste del bosque, la salida se ilumina." if Juego.ayudo_a_vale else "Pero antes de salir, busca a Vale en La Ansiedad."
		]))

	queue_free()
