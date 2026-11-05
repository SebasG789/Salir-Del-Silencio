# ------------------------------------------------------------------
# PANEL DE INSTRUCCIONES
# Se usa en el menú principal y en la pausa.
# Se baja con la rueda del mouse o con las flechas, y se cierra con Esc.
# ------------------------------------------------------------------
class_name Instrucciones
extends PanelContainer

signal cerrado

@onready var scroll: ScrollContainer = $Margen/VBox/Scroll
@onready var boton_volver: Button = $Margen/VBox/Volver


func abrir() -> void:
	visible = true
	centrar()
	scroll.scroll_vertical = 0
	boton_volver.grab_focus()


# Se centra en pantalla por código: al estar dentro de otra escena
# (menú o pausa) Godot a veces pierde el centrado del panel.
func centrar() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	size = custom_minimum_size
	position = (get_viewport_rect().size - size) / 2.0


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		cerrar()
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("ABAJO"):
		get_viewport().set_input_as_handled()
		scroll.scroll_vertical += 24
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ARRIBA"):
		get_viewport().set_input_as_handled()
		scroll.scroll_vertical -= 24


func _on_volver_pressed() -> void:
	cerrar()
