# ------------------------------------------------------------------
# PANTALLA FINAL
# ------------------------------------------------------------------
extends Control

@onready var textos: VBoxContainer = $Textos
@onready var trivia: Label = $Textos/Trivia
@onready var boton_menu: Button = $Textos/Menu
@onready var blanco: ColorRect = $Blanco


func _ready() -> void:
	get_tree().paused = false
	Audio.musica("final")

	if Juego.puntaje_trivia >= 0:
		trivia.text = "En la trivia del inicio acertaste %d de %d. ¿Cambió algo lo que piensas?" % [Juego.puntaje_trivia, Juego.total_trivia]
	else:
		trivia.visible = false

	# Cada texto aparece uno por uno
	for hijo in textos.get_children():
		(hijo as Control).modulate.a = 0.0

	# Viene de la luz de la salida: el blanco se desvanece
	var tween := create_tween()
	tween.tween_property(blanco, "color:a", 0.0, 1.5)
	for hijo in textos.get_children():
		tween.tween_property(hijo, "modulate:a", 1.0, 1.0)
		tween.tween_interval(0.4)
	await tween.finished
	boton_menu.grab_focus()


# Después del final viene la trivia final para medir lo aprendido
func _on_menu_pressed() -> void:
	Audio.sonido("boton")
	Juego.modo_trivia = "final"
	get_tree().change_scene_to_file("res://escenas/trivia.tscn")
