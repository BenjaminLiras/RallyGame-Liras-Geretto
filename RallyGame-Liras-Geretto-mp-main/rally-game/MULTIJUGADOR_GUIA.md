# Sistema de Multijugador Local - Guía de Implementación

## Descripción
Sistema de multijugador local para RallyGame que permite a 2 jugadores competir simultáneamente en el mismo circuito con controles independientes.

## Características
- **2 Jugadores simultáneos** en el mismo circuito
- **Controles independientes**:
  - Jugador 1: Flechas Arriba/Abajo
  - Jugador 2: W/S
- **Ventana de decisión**: 1.5 segundos para tomar decisiones en puntos críticos
- **UI en tiempo real**: Muestra daño, velocidad y estado de ambos jugadores
- **Sistema de penalizaciones**: Diferentes castigos según la decisión tomada

## Estructura de Archivos

### Scripts Nuevos
1. **multiplayer_manager.gd** - Gestor principal del sistema multijugador
   - Controla ambos jugadores
   - Maneja el temporizador de decisiones
   - Procesa inputs de ambos jugadores
   - Aplica efectos de las decisiones

2. **multiplayer_ui.gd** - Interfaz de usuario del multijugador
   - Muestra información de ambos jugadores
   - Pantalla de timer de decisiones
   - Indicadores de estado

3. **input_setup.gd** - Configuración de inputs
   - Registra las acciones W/S en el InputMap

## Cómo Integrar

### 1. Agregar el Gestor de Multijugador a la Escena Principal

Abre `Scenes/Main.tscn` y:
- Agrega un nodo Node llamado "MultiplayerManager"
- Asigna el script `multiplayer_manager.gd` a este nodo
- Agrega un nodo Control como hijo de MultiplayerManager
- Asigna el script `multiplayer_ui.gd` al nodo Control

### 2. Configurar las Referencias de PathFollow2D

En el script `stage.gd`, en la función `_ready()`, agrega:

```gdscript
func _ready() -> void:
	# Obtener referencia al multiplicador de jugadores
	var multiplayer_manager = get_node("MultiplayerManager")
	var car_paths = [
		get_node("prota"),      # PathFollow2D del Jugador 1
		get_node("Car2")        # PathFollow2D del Jugador 2
	]
	multiplayer_manager.inicializar_jugadores(car_paths)
```

### 3. Conectar la Detección de Zonas

En `path_follow_2d.gd`, modifica `_on_zona_curva_detectada()`:

```gdscript
func _on_zona_curva_detectada(area: Area2D) -> void:
	var multiplayer_manager = get_node("../../MultiplayerManager")
	multiplayer_manager.zona_curva_detectada(area)
```

## Sistema de Decisiones

### Tipos de Decisión
1. **ATACAR** (Flecha Arriba / W)
   - Velocidad: 1.2x
   - Daño: 12 + (velocidad_excesiva * 45)

2. **MODERAR** (Flecha Abajo para J1 / S para J2)
   - Velocidad: 0.7x (Jugador 1)
   - Velocidad: 0.6x (Jugador 2)
   - Daño: 5

3. **CONSERVAR** (Segunda Flecha Abajo / S)
   - Velocidad: 0.6x
   - Daño: 0

4. **NINGUNA** (Timeout de 1.5s)
   - Velocidad: 0.5x
   - Daño: 10

## Mecánica de Juego

### Cuando Comienza una Decisión
1. El auto detecta una zona de curva crítica
2. Se inicia el temporizador de 1.5 segundos
3. Se muestra en la UI el contador regresivo
4. Ambos jugadores tienen ese tiempo para decidir

### Resolución
- Apenas un jugador toma decisión, se registra
- Si ambos deciden antes de tiempo, se ejecutan inmediatamente
- Si vence el tiempo, se aplica penalización automática

## Estados de Jugador

Cada jugador tiene:
- **Daño**: Valor entre 0-100 (0 = descalificado)
- **Velocidad**: Factor multiplicador de velocidad
- **Estado**: OK o DESCALIFICADO
- **Última Decisión**: La última acción tomada

## Exportables (Configurables en Inspector)

### MultiplayerManager
- `tiempo_decision`: Duración de la ventana de decisión (default: 1.5s)
- `velocidad_defaul`: Velocidad de referencia (default: 1.0)
- `suavizado_aceleracion`: Suavidad al acelerar
- `suavizado_frenado`: Suavidad al frenar

### MultiplayerUI
- `mostrar_debug`: Mostrar información de debug

## Pruebas Rápidas

1. Copia el proyecto actualizado
2. Abre `Scenes/Main.tscn`
3. Ejecuta el juego (F5)
4. Navega hasta una zona de decisión
5. Prueba los controles:
   - Jugador 1: ↑ (atacar), ↓ (moderar)
   - Jugador 2: W (atacar), S (frenar/conservar)

## Notas Técnicas

- El sistema usa `get_tree().paused` para pausar ambos jugadores durante las decisiones
- Los inputs se consumen automáticamente cuando hay una decisión activa
- Los tweens de animación respetan el estado paused

## Futuras Mejoras

- [ ] Sistema de puntuación competitiva
- [ ] Replay instantáneo de decisiones
- [ ] Sonidos de decisión
- [ ] Efectos visuales para cada tipo de decisión
- [ ] Modo online (networking)
- [ ] Guardado de replays
