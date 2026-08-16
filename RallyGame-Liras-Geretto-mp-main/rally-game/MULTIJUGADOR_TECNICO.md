# Sistema de Multijugador - Documentación Técnica

## Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                      Main (Escena Principal)                 │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────────┐ │
│ │  Stage (Path2D)                                         │ │
│ │  ├─ prota (PathFollow2D) - Jugador 1                    │ │
│ │  ├─ Car2 (PathFollow2D) - Jugador 2                     │ │
│ │  ├─ Area2D (zonas de decisión)                          │ │
│ │  └─ TileMapLayer (pista)                                │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │  MultiplayerManager (Node) - NUEVO                      │ │
│ │  ├─ Control (UI)                                        │ │
│ │  │  ├─ Label Daño J1                                    │ │
│ │  │  ├─ Label Velocidad J1                               │ │
│ │  │  ├─ Label Daño J2                                    │ │
│ │  │  ├─ Label Velocidad J2                               │ │
│ │  │  └─ Label Timer                                      │ │
│ │  └─ [Gestiona lógica de ambos jugadores]                │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │  CanvasLayer                                            │ │
│ │  └─ Cartel (Control) - Panel de decisión                │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Flujo de Ejecución

### 1. Inicialización
```
_ready() del Stage
    ↓
Obtiene referencias a "prota" y "Car2"
    ↓
Llama a multiplayer_manager.inicializar_jugadores([prota, Car2])
    ↓
Se crean dos instancias de clase Jugador
    ↓
Se inicializan variables de cada jugador
```

### 2. Detectar Curva/Decisión
```
Area2D detecta colisión con PathFollow2D
    ↓
Llama a multiplayer_manager.zona_curva_detectada(area)
    ↓
Si es punto de decisión (tipo != 1):
    - Inicia ronda de decisiones
    - Inicia timer de 1.5s
    - Espera inputs de ambos jugadores
```

### 3. Procesamiento de Decisiones
```
Cada frame:
    - Verifica si hay inputs pendientes (W/S/↑/↓)
    - Registra decisiones de cada jugador
    - Si ambos decidieron O timeout:
        → finalizar_ronda_decisiones()
```

### 4. Aplicar Decisiones
```
Para cada jugador:
    - Calcular modificador de velocidad según decisión
    - Aplicar daño si corresponde
    - Animar cambio de velocidad
    - Verificar si está descalificado
```

## Ejemplo de Código de Integración

### En stage.gd
```gdscript
func _ready() -> void:
	var multiplayer_manager = get_node("MultiplayerManager")
	var car_paths = [get_node("prota"), get_node("Car2")]
	multiplayer_manager.inicializar_jugadores(car_paths)
```

### En path_follow_2d.gd (modificado)
```gdscript
func _ready() -> void:
	loop = true
	multiplayer_manager = get_node_or_null("../../MultiplayerManager")
	
	if multiplayer_manager:
		# Modo multijugador: no conectar señales
		print("Modo multijugador activado")
	else:
		# Modo single-player: comportamiento original
		$Area2D.area_entered.connect(_on_zona_curva_detectada)

func _on_zona_curva_detectada(area: Area2D) -> void:
	if multiplayer_manager:
		multiplayer_manager.zona_curva_detectada(area)
	else:
		# Código single-player original
		pass
```

## Manejo de Estados

### Estado de Jugador (Clase interna)
```
class Jugador:
	var id: int                              # 1 o 2
	var pathfollow: PathFollow2D             # Nodo en escena
	var tecla_arriba: String                 # "ui_up" o "w_key"
	var tecla_abajo: String                  # "ui_down" o "s_key"
	var decision_actual: int                 # TipoDecision enum
	var decision_tomada: bool                # ¿Ya decidió?
	var factor_velocidad_actual: float       # Velocidad actual
	var factor_velocidad_objetivo: float     # Velocidad objetivo
	var velocidad_segura_punto_actual: float # Límite de seguridad
	var danio: float                         # Daño restante
	var descalificado: bool                  # ¿Fue eliminado?
	var curva_actual: Area2D                 # Zona actual
```

### Transiciones de Velocidad
```
Velocidad actual → (suavizado) → Velocidad objetivo

Suavizado:
- Si acelera: 2.5 * delta (más rápido)
- Si frena: 4.0 * delta (más lento)
```

## Sistema de Daño

### Fórmula de Daño por ATACAR
```
Daño = 12 + (exceso_de_velocidad * 45)

Donde:
  exceso_de_velocidad = max(0, velocidad_actual - velocidad_segura)
```

### Tabla de Daño por Decisión
```
ATACAR:     castigo_base + (exceso * 45)  [variable, 12+]
MODERAR:    5 puntos fijos
CONSERVAR:  0 puntos
TIMEOUT:    10 puntos fijos (penalización automática)
```

## Sistema de Entrada

### InputMap (Configurado en input_setup.gd)
```
Acciones originales (Jugador 1):
  - ui_up      → KEY_UP
  - ui_down    → KEY_DOWN

Acciones nuevas (Jugador 2):
  - w_key      → KEY_W
  - s_key      → KEY_S
```

### Procesamiento de Input
```
_input(event):
    Si NO esperando_decisiones → retornar
    
    Para cada jugador:
        Si ya decidió → continuar
        Si presiona tecla_arriba:
            → registrar_decision(ATACAR)
        Si presiona tecla_abajo:
            → registrar_decision(MODERAR/CONSERVAR)
```

## Temporizador de Decisiones

### Lógica
```
_process(delta):
    Si esperando_decisiones:
        decision_timer -= delta
        
        Si decision_timer <= 0:
            finalizar_ronda_decisiones()
        
        Si todas_decisiones_tomadas():
            finalizar_ronda_decisiones()
```

### Estados del Timer
```
1.5s → Espera inputs de ambos jugadores
0.0s → Timeout, aplicar penalización automática
```

## Ejemplos de Uso

### Obtener Estado de un Jugador
```gdscript
var estado_j1 = multiplayer_manager.obtener_estado_jugador(1)
print("Daño:", estado_j1.danio)
print("Velocidad:", estado_j1.velocidad)
print("Descalificado:", estado_j1.descalificado)
```

### Obtener Estado General
```gdscript
var estado_general = multiplayer_manager.obtener_estado_ambos()
if estado_general.esperando_decisiones:
    print("Tiempo restante:", estado_general.tiempo_restante)
```

### Conectar Señal de Zona
```gdscript
# En algún script que maneje las zonas:
$Area2D.area_entered.connect(
    func(area):
        multiplayer_manager.zona_curva_detectada(area)
)
```

## Notas de Implementación

### Thread Safety
- No hay threading, todo es secuencial en el thread principal

### Performance
- 2 jugadores simultáneos tiene bajo overhead
- Caché de referencias en _ready()
- Sin búsquedas por nodo en _process()

### Extensibilidad
- Sistema de clase interna permite agregar jugadores fácilmente
- Métodos públicos para consultar estado
- Enum TipoDecision puede extenderse con nuevas opciones

## Debugging

### Habilitar Logs
```gdscript
# En multiplayer_manager.gd, agregar:
var debug = true

if debug:
    print("Ronda iniciada. Timer: %f" % tiempo_decision)
    print("Jugador %d decidió: %s" % [jugador.id, nombres_decision[decision]])
```

### Verificar Estado
```gdscript
# En _process():
var estado = multiplayer_manager.obtener_estado_ambos()
print(JSON.stringify(estado, "\t"))
```

## Posibles Errores y Soluciones

### "MultiplayerManager no encontrado"
→ Verifica que exista un nodo llamado "MultiplayerManager" en Main.tscn

### "No se encontró prota (Jugador 1)"
→ Verifica que el PathFollow2D se llama exactamente "prota"

### Inputs no funcionan
→ Asegúrate de que input_setup.gd se ejecute (debe estar en autoload)

### Las decisiones no se aplican
→ Verifica que zone_curva_detectada esté conectada correctamente
