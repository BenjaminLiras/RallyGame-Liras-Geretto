extends PathFollow2D

@export var velocidad: float = 300
@export_range(0.0, 2.0, 0.05) var velocidad_defaul: float = 1.0
@export_range(0.5, 8.0, 0.1) var suavizado_aceleracion: float = 2.5
@export_range(0.5, 8.0, 0.1) var suavizado_frenado: float = 4.0
@export var danio: float = 100
@export_range(0.0, 100.0, 1.0) var danio_minimo: float = 0.0
@export_range(0.0, 100.0, 1.0) var danio_maximo: float = 100.0
@export_range(1.0, 40.0, 1.0) var castigo_base_atacar: float = 12.0
@export_range(5.0, 120.0, 1.0) var castigo_por_exceso_velocidad: float = 45.0

@onready var menu_decision = $"../../CanvasLayer/Cartel"
@onready var detector_area: Area2D = $Area2D
@onready var sprite_auto: Sprite2D = $Sprite2D

var curva_actual: Area2D = null
var factor_velocidad_actual: float = 1.0
var factor_velocidad_objetivo: float = 1.0
var velocidad_segura_punto_actual: float = 1.0
var juego_pausado_por_decision: bool = false
var descalificado_por_demolicion: bool = false

enum TipoDecision {
	ATACAR,
	MODERAR,
	CONSERVAR,
}

func _ready() -> void:
	loop = true
	factor_velocidad_actual = velocidad_defaul
	factor_velocidad_objetivo = velocidad_defaul
	velocidad_segura_punto_actual = velocidad_defaul
	menu_decision.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	menu_decision.visible = false
	$Area2D.area_entered.connect(_on_zona_curva_detectada)
	menu_decision.get_node("Button").pressed.connect(_on_acelerar)
	menu_decision.get_node("Button2").pressed.connect(_on_frenar)
	menu_decision.get_node("Button3").pressed.connect(_on_segunda)
				
	
func _process(delta: float) -> void:
	if descalificado_por_demolicion:
		return

	var suavizado_actual = suavizado_frenado
	if factor_velocidad_objetivo > factor_velocidad_actual:
		suavizado_actual = suavizado_aceleracion
	
	factor_velocidad_actual = move_toward(
		factor_velocidad_actual,
		factor_velocidad_objetivo,
		suavizado_actual * delta
	)
	
	
	progress += velocidad * factor_velocidad_actual * delta
	print(danio)
	
func _on_zona_curva_detectada(area: Area2D) -> void:
	if descalificado_por_demolicion:
		return

	var tipo_punto = area.get("tipo_punto")
	if tipo_punto == null:
		return
	
	var nueva_velocidad_objetivo = area.get("velocidad_objetivo")
	if nueva_velocidad_objetivo == null:
		nueva_velocidad_objetivo = velocidad_defaul
	
	if tipo_punto == 1:
		curva_actual = null
		factor_velocidad_objetivo = float(nueva_velocidad_objetivo)
		menu_decision.visible = false
		reanudar_juego_por_decision()
		return
	
	curva_actual = area
	factor_velocidad_objetivo = nueva_velocidad_objetivo
	velocidad_segura_punto_actual = nueva_velocidad_objetivo
	menu_decision.visible = bool(area.get("mostrar_menu"))
	if menu_decision.visible:
		pausar_juego_por_decision()
	
	
func tomar_decision(modificador_velocidad: float) -> void:
	factor_velocidad_objetivo = modificador_velocidad
	curva_actual = null
	menu_decision.visible = false
	reanudar_juego_por_decision()
	

func pausar_juego_por_decision() -> void:
	if juego_pausado_por_decision:
		return
	juego_pausado_por_decision = true
	get_tree().paused = true
	

func reanudar_juego_por_decision() -> void:
	if not juego_pausado_por_decision:
		return
	juego_pausado_por_decision = false
	get_tree().paused = false
	

func recibir_danio(cantidad: float) -> void:
	if descalificado_por_demolicion:
		return
	
	danio -= cantidad
	if danio < danio_minimo:
		danio = danio_minimo
	
	if danio <= danio_minimo:
		descalificar_por_demolicion()
	

func descalificar_por_demolicion() -> void:
	if descalificado_por_demolicion:
		return
	
	descalificado_por_demolicion = true
	reanudar_juego_por_decision()
	menu_decision.visible = false
	curva_actual = null
	factor_velocidad_actual = 0.0
	factor_velocidad_objetivo = 0.0
	
	#Animacion fachera de destruccion del auto
	var tween = create_tween()
	tween.tween_property(self, "v_offset", 220.0, 0.6)
	

func calcular_castigo_atacar() -> float:
	var exceso_velocidad = max(0.0, factor_velocidad_actual - velocidad_segura_punto_actual)
	return castigo_base_atacar + (exceso_velocidad * castigo_por_exceso_velocidad)
	
	
func resolver_decision(tipo_decision: TipoDecision) -> void:
	match tipo_decision:
		TipoDecision.ATACAR:
			tomar_decision(1.2)
			recibir_danio(calcular_castigo_atacar())
		TipoDecision.MODERAR:
			tomar_decision(0.7)
			recibir_danio(5.0)
		TipoDecision.CONSERVAR:
			tomar_decision(0.6)
		

func _on_acelerar() -> void:
	resolver_decision(TipoDecision.ATACAR)
	
	

func _on_frenar() -> void:
	resolver_decision(TipoDecision.MODERAR)
	

func _on_segunda() -> void:
	resolver_decision(TipoDecision.CONSERVAR)
