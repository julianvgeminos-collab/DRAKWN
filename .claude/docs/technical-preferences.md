# Technical Preferences

<!-- Populated by /setup-engine. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Godot 4.6.3
- **Language**: GDScript (gameplay/UI scripting), C# (performance-critical systems), C++ via GDExtension (native only)
- **Rendering**: 2D CanvasItem / Viewport (2D metroidvania — no 3D)
- **Physics**: Jolt Physics (default en Godot 4.6)

## Input & Platform

<!-- Written by /setup-engine. Read by /ux-design, /ux-review, /test-setup, /team-ui, and /dev-story -->
<!-- to scope interaction specs, test helpers, and implementation to the correct input methods. -->

- **Target Platforms**: PC (Steam)
- **Input Methods**: Keyboard/Mouse, Gamepad
- **Primary Input**: Keyboard/Mouse (menús) / Gamepad (combate — recomendado para metroidvania)
- **Gamepad Support**: Partial (soporte completo recomendado para mejor feel de combate)
- **Touch Support**: None
- **Platform Notes**: Toda UI debe soportar navegación con d-pad. Sin interacciones hover-only. Input remapping requerido para accesibilidad básica.

## Naming Conventions

### GDScript (.gd files)
- **Classes**: PascalCase (`PlayerController`, `DragonBoss`)
- **Variables/funciones**: snake_case (`move_speed`, `take_damage()`)
- **Signals**: snake_case past tense (`health_changed`, `power_absorbed`)
- **Files**: snake_case matching clase (`player_controller.gd`)
- **Scenes**: PascalCase matching root node (`PlayerController.tscn`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_HEALTH`, `BASE_DAMAGE`)

### C# (.cs files)
- **Classes**: PascalCase, siempre `partial` (`PlayerController`, `MasterySystem`)
- **Public properties/fields**: PascalCase (`MoveSpeed`, `CurrentHealth`)
- **Private fields**: `_camelCase` (`_currentHealth`, `_isGrounded`)
- **Methods**: PascalCase (`TakeDamage()`, `AbsorbDragonPower()`)
- **Signal delegates**: PascalCase + `EventHandler` (`HealthChangedEventHandler`)
- **Files**: PascalCase matching clase (`PlayerController.cs`)
- **Constants**: PascalCase (`MaxHealth`, `DefaultMoveSpeed`)

### Cross-language boundary
- Usar signals para comunicación GDScript ↔ C# — no llamadas directas cross-language
- Si hay duda sobre qué lenguaje usar para un sistema nuevo, consultar con `godot-specialist`
- La frontera se decide por archivo: `.gd` = GDScript, `.cs` = C#

## Performance Budgets

- **Target Framerate**: 60 FPS
- **Frame Budget**: 16.6ms
- **Draw Calls**: ~500 máximo (2D metroidvania — ajustar según profiling real)
- **Memory Ceiling**: Por determinar después del primer perfil de memoria real

## Testing

- **Framework GDScript**: GUT (Godot Unit Testing framework)
- **Framework C#**: NUnit (.NET)
- **Minimum Coverage**: Sistemas de gameplay lógico (fórmulas, maestría, poderes de dragón)
- **Required Tests**: Balance de daño/poder, state machine del jugador, absorción de poderes

## Forbidden Patterns

<!-- Add patterns that should never appear in this project's codebase -->
- [Ninguno configurado aún — añadir cuando se tomen decisiones arquitectónicas]

## Allowed Libraries / Addons

<!-- Add approved third-party dependencies here — ONLY when actively integrating, never speculatively -->
- [Ninguno configurado aún — añadir solo cuando se integre activamente]

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [Sin ADRs aún — usar /architecture-decision para crear]

## Engine Specialists

<!-- Written by /setup-engine when engine is configured. -->
<!-- Read by /code-review, /architecture-decision, /architecture-review, and team skills -->
<!-- to know which specialist to spawn for engine-specific validation. -->

- **Primary**: godot-specialist
- **GDScript Specialist**: godot-gdscript-specialist (.gd files — gameplay/UI scripts)
- **C# Specialist**: godot-csharp-specialist (.cs files — performance-critical systems)
- **Shader Specialist**: godot-shader-specialist (.gdshader — sistema de paleta dinámica Fractura Sagrada)
- **UI Specialist**: godot-specialist (no hay especialista UI dedicado — primary cubre toda la UI)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / C++ nativo — solo si necesario)
- **Routing Notes**: Invocar primary para arquitectura cross-cutting y decisiones de qué lenguaje usar. Invocar GDScript specialist para .gd (gameplay, señales, tipado estático). Invocar C# specialist para .cs y .csproj. Invocar shader specialist para el sistema de paleta dinámica Fractura Sagrada y todos los shaders. Preferir signals sobre llamadas directas cross-language en la frontera GDScript/C#.

### File Extension Routing

<!-- Skills use this table to select the right specialist per file type. -->

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.gd files) | godot-gdscript-specialist |
| Game code (.cs files) | godot-csharp-specialist |
| Cross-language boundary decisions | godot-specialist |
| Shader / material files (.gdshader, VisualShader) | godot-shader-specialist |
| UI / screen files (Control nodes, CanvasLayer) | godot-specialist |
| Scene / prefab / level files (.tscn, .tres) | godot-specialist |
| Project config (.csproj, NuGet) | godot-csharp-specialist |
| Native extension / plugin files (.gdextension, C++) | godot-gdextension-specialist |
| General architecture review | godot-specialist |
