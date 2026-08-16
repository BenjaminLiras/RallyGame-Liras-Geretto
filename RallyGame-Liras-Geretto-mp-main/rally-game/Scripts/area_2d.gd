extends Area2D

enum TipoPunto {
	DECISION,
	RECUPERACION,
}

@export var tipo_punto: TipoPunto = TipoPunto.DECISION
@export_range(0.0, 2.0, 0.05) var velocidad_objetivo: float = 0.0
@export var mostrar_menu: bool = true
