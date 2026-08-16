## NOTA: Este archivo es una REFERENCIA de cómo adaptar path_follow_2d.gd
## para trabajar con el sistema multijugador.
## 
## Para usar el multijugador, necesitas modificar tu path_follow_2d.gd existente
## reemplazando o comentando las secciones que manejaban un solo jugador.

extends PathFollow2D

@export var velocidad: float = 300
@export_range(0.0, 2.0, 0.05) var velocidad_defaul: float = 1.0
@export_range(0.5, 8.0, 0.1) var suavizado_aceleracion: float = 2.5
@export_range(0.5, 8.0, 0.1) var suavizado_frenado: float = 4.0
@export var danio: float = 100

@onready var menu_decision = $"../../CanvasLayer/Cartel"
@onready var multiplayer_manager = get_node_or_null("../../MultiplayerManager")

var usar_multijugador: bool = false

func _ready() -> void:
	loop = true
	
	# Detectar si estamos en modo multijugador
	usar_multijugador = multiplayer_manager != null and multiplayer_manager.has_method("inicializar_jugadores")
	
	if usar_multijugador:
		print("✓ %s en modo multijugador" % name)
		# En multijugador, el sistema es manejado por MultiplayerManager
		# Este nodo solo ejecuta las acciones que le indica
		menu_decision.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		menu_decision.visible = false
	else:
		print("ℹ %s en modo single-player" % name)
		# Modo single-player: comportamiento original
		menu_decision.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		menu_decision.visible = false
		$Area2D.area_entered.connect(_on_zona_curva_detectada)
		menu_decision.get_node("Button").pressed.connect(_on_acelerar)
		menu_decision.get_node("Button2").pressed.connect(_on_frenar)
		menu_decision.get_node("Button3").pressed.connect(_on_segunda)

func _process(delta: float) -> void:
	if usar_multijugador:
		# En multijugador, el movimiento es controlado por MultiplayerManager
		return
	
	# Código original para single-player
	pass

# MÉTODOS PARA MULTIJUGADOR
# Estos métodos son llamados por MultiplayerManager

func establecer_velocidad_objetivo(velocidad_objetivo: float) -> void:
	"""Establece el objetivo de velocidad (llamado por MultiplayerManager)"""
	# Este método debería actualizar la velocidad del jugador
	pass

func recibir_danio_multijugador(cantidad: float) -> void:
	"""Recibe daño en modo multijugador"""
	danio -= cantidad
	if danio < 0:
		danio = 0
		descalificar()

func descalificar() -> void:
	"""Descalifica este jugador"""
	# Animación de destrucción
	var tween = create_tween()
	tween.tween_property(self, "v_offset", 220.0, 0.6)

# MÉTODOS ORIGINALES (Solo para single-player)

func _on_zona_curva_detectada(area: Area2D) -> void:
	if usar_multijugador:
		# En multijugador, delegar al manager
		if multiplayer_manager:
			multiplayer_manager.zona_curva_detectada(area)
		return
	
	# Código original para single-player
	pass

func _on_acelerar() -> void:
	if usar_multijugador:
		return
	pass

func _on_frenar() -> void:
	if usar_multijugador:
		return
	pass

func _on_segunda() -> void:
	if usar_multijugador:
		return
	pass
