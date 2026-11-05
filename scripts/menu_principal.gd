# ------------------------------------------------------------------
# MENU PRINCIPAL: Jugar (va a la trivia), Instrucciones, Salir
# ------------------------------------------------------------------
extends Control

@onready var fondo: TextureRect = $Fondo
@onready var titulo: Label = $Titulo
@onready var boton_jugar: Button = $Botones/Jugar
@onready var instrucciones: Instrucciones = $Instrucciones


func _ready() -> void:
	get_tree().paused = false
	Audio.musica("menu")
	instrucciones.visible = false
	instrucciones.cerrado.connect(_on_instrucciones_cerrado)
	boton_jugar.grab_focus()
	mover_fondo()
	animar_titulo()


# El mapa se desplaza de lado a lado detrás del menú
func mover_fondo() -> void:
	var alto := get_viewport_rect().size.y
	var ancho := alto * fondo.texture.get_width() / fondo.texture.get_height()
	fondo.size = Vector2(ancho, alto)
	fondo.position = Vector2.ZERO
	var recorrido := ancho - get_viewport_rect().size.x

	var tween := create_tween().set_loops()
	tween.tween_property(fondo, "position:x", -recorrido, 14.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(fondo, "position:x", 0.0, 14.0).set_trans(Tween.TRANS_SINE)


# El título aparece y luego "respira" suavemente
func animar_titulo() -> void:
	titulo.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(titulo, "modulate:a", 1.0, 0.8)
	var pulso := create_tween().set_loops()
	pulso.tween_property(titulo, "scale", Vector2(1.03, 1.03), 1.6).set_trans(Tween.TRANS_SINE)
	pulso.tween_property(titulo, "scale", Vector2.ONE, 1.6).set_trans(Tween.TRANS_SINE)


func _on_jugar_pressed() -> void:
	Audio.sonido("boton")
	Juego.modo_trivia = "inicial"
	get_tree().change_scene_to_file("res://escenas/trivia.tscn")


func _on_instrucciones_pressed() -> void:
	Audio.sonido("boton")
	instrucciones.abrir()


func _on_instrucciones_cerrado() -> void:
	boton_jugar.grab_focus()


func _on_salir_pressed() -> void:
	get_tree().quit()
