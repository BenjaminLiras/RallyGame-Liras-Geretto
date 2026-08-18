extends Control

class_name MultiplayerUI

@onready var multiplayer_manager: MultiplayerManager = $".."
@export var mostrar_debug: bool = true

# Nodos de UI para cada jugador
var label_j1_danio: Label
var label_j1_velocidad: Label
var label_j1_decision: Label
var label_j1_estado: Label

var label_j2_danio: Label
var label_j2_velocidad: Label
var label_j2_decision: Label
var label_j2_estado: Label

var label_timer: Label
var color_esperando: Color = Color.YELLOW
var color_normal: Color = Color.WHITE

func _ready() -> void:
	crear_ui()

func crear_ui() -> void:	# Panel izquierdo para Jugador 1
	var panel_j1 = PanelContainer.new()
	panel_j1.anchor_left = 0.0
	panel_j1.anchor_top = 0.0
	panel_j1.anchor_right = 0.3
	panel_j1.anchor_bottom = 0.25
	panel_j1.offset_left = 10
	panel_j1.offset_top = 10
	panel_j1.modulate = Color(0.2, 0.2, 0.8, 0.8)
	add_child(panel_j1)
	
	var vbox_j1 = VBoxContainer.new()
	panel_j1.add_child(vbox_j1)
	
	var label_j1_titulo = Label.new()
	label_j1_titulo.text = "JUGADOR 1 (↑↓)"
	label_j1_titulo.add_theme_font_size_override("font_size", 16)
	vbox_j1.add_child(label_j1_titulo)
	
	label_j1_danio = Label.new()
	label_j1_danio.text = "Daño: 100%"
	vbox_j1.add_child(label_j1_danio)
	
	label_j1_velocidad = Label.new()
	label_j1_velocidad.text = "Velocidad: 1.0x"
	vbox_j1.add_child(label_j1_velocidad)
	
	label_j1_decision = Label.new()
	label_j1_decision.text = "Última decisión: -"
	vbox_j1.add_child(label_j1_decision)
	
	label_j1_estado = Label.new()
	label_j1_estado.text = "Estado: OK"
	vbox_j1.add_child(label_j1_estado)
	
	# Panel derecho para Jugador 2
	var panel_j2 = PanelContainer.new()
	panel_j2.anchor_left = 0.7
	panel_j2.anchor_top = 0.0
	panel_j2.anchor_right = 1.0
	panel_j2.anchor_bottom = 0.25
	panel_j2.offset_left = -10
	panel_j2.offset_top = 10
	panel_j2.offset_right = -10
	panel_j2.modulate = Color(0.8, 0.2, 0.2, 0.8)
	add_child(panel_j2)
	
	var vbox_j2 = VBoxContainer.new()
	panel_j2.add_child(vbox_j2)
	
	var label_j2_titulo = Label.new()
	label_j2_titulo.text = "JUGADOR 2 (W/S)"
	label_j2_titulo.add_theme_font_size_override("font_size", 16)
	vbox_j2.add_child(label_j2_titulo)
	
	label_j2_danio = Label.new()
	label_j2_danio.text = "Daño: 100%"
	vbox_j2.add_child(label_j2_danio)
	
	label_j2_velocidad = Label.new()
	label_j2_velocidad.text = "Velocidad: 1.0x"
	vbox_j2.add_child(label_j2_velocidad)
	
	label_j2_decision = Label.new()
	label_j2_decision.text = "Última decisión: -"
	vbox_j2.add_child(label_j2_decision)
	
	label_j2_estado = Label.new()
	label_j2_estado.text = "Estado: OK"
	vbox_j2.add_child(label_j2_estado)
	
	# Panel central superior para timer de decisión
	var panel_timer = PanelContainer.new()
	panel_timer.anchor_left = 0.35
	panel_timer.anchor_top = 0.0
	panel_timer.anchor_right = 0.65
	panel_timer.anchor_bottom = 0.08
	panel_timer.offset_top = 10
	panel_timer.modulate = Color(0.3, 0.3, 0.3, 0.8)
	add_child(panel_timer)
	
	var hbox_timer = HBoxContainer.new()
	panel_timer.add_child(hbox_timer)
	
	label_timer = Label.new()
	label_timer.text = "Tiempo: 1.5s"
	label_timer.add_theme_font_size_override("font_size", 14)
	label_timer.custom_minimum_size = Vector2(200, 30)
	hbox_timer.add_child(label_timer)

func _process(delta: float) -> void:
	if not multiplayer_manager:
		return
	
	actualizar_ui()

func actualizar_ui() -> void:
	var estado = multiplayer_manager.obtener_estado_ambos()
	
	# Actualizar Jugador 1
	if "jugador1" in estado and not estado.jugador1.is_empty():
		var j1 = estado.jugador1
		label_j1_danio.text = "Daño: %.1f%%" % j1.danio
		label_j1_velocidad.text = "Velocidad: %.2fx" % j1.velocidad
		label_j1_decision.text = "Última decisión: %s" % obtener_nombre_decision(j1.decision_ultima)
		label_j1_estado.text = "Estado: %s" % ("DESCALIFICADO" if j1.descalificado else "OK")
	
	# Actualizar Jugador 2
	if "jugador2" in estado and not estado.jugador2.is_empty():
		var j2 = estado.jugador2
		label_j2_danio.text = "Daño: %.1f%%" % j2.danio
		label_j2_velocidad.text = "Velocidad: %.2fx" % j2.velocidad
		label_j2_decision.text = "Última decisión: %s" % obtener_nombre_decision(j2.decision_ultima)
		label_j2_estado.text = "Estado: %s" % ("DESCALIFICADO" if j2.descalificado else "OK")
	
	# Actualizar timer
	if estado.esperando_decisiones:
		label_timer.text = "Tiempo: %.1fs" % max(0.0, estado.tiempo_restante)
		label_timer.add_theme_color_override("font_color", color_esperando)
	else:
		label_timer.text = "Esperando curva..."
		label_timer.add_theme_color_override("font_color", color_normal)

func obtener_nombre_decision(tipo_decision: int) -> String:
	match tipo_decision:
		0:  # ATACAR
			return "ATACAR"
		1:  # MODERAR
			return "MODERAR"
		2:  # CONSERVAR
			return "CONSERVAR"
		3:  # NINGUNA
			return "NINGUNA (Timeout)"
		_:
			return "-"
