# EXPERIENCE 10 — Safety Plan & Mood Intelligence

## Objetivo
Crear el espacio más sensible de OASIS para acompañar momentos emocionales difíciles desde calma, seguridad, esperanza y reducción de fricción.

## Resultado Entregado

### 1. Safety Plan completo
Se creó un módulo independiente bajo `features/safety_plan/` con arquitectura limpia completa:
- `domain`
- `data`
- `presentation`
- `providers`
- `screens`

Incluye los 6 pasos solicitados:
1. Señales de crisis
2. Qué puedo hacer por mí mismo
3. Lugares seguros
4. Personas que puedo contactar
5. Profesionales
6. Motivos para seguir

### 2. Modo Crisis
Se implementó un modo crisis activado por el botón persistente `No estoy bien`.

Comportamiento:
- reduce movimiento (`CanvasMotionPreference.off`)
- desactiva animación de entrada del shell
- aumenta tamaño visual del contenido mediante `TextScaler`
- usa contraste más alto y cálido
- muestra solo:
  - Respirar
  - Mis motivos
  - Mis contactos
  - Mi plan

### 3. Botón persistente de crisis
Se integró acceso persistente a Safety Plan desde el scaffold global mediante `EmergencyButton`.

### 4. Journal expandido
`JournalEntry` dejó de ser solo un registro simple y ahora soporta:
- estado de ánimo principal
- emociones secundarias
- intensidad
- energía
- horas de sueño
- ansiedad
- irritabilidad
- medicación tomada
- dolor
- estrés
- gratitude
- reflexión de aprendizaje
- checklist de self-care

### 5. Insights sin IA
Se implementaron reglas simples en Journal:
- 3 días de ansiedad elevada
- falta de medicación en días recientes
- ausencia de hidratación semanal
- estrés e irritabilidad altos sostenidos

No se conectó IA ni servicios externos.

### 6. ODL nuevos componentes
Se crearon:
- `SafetySection`
- `ReflectionCard`
- `MoodIntensitySlider`
- `EmotionCloud`
- `InsightCard`
- `HopeCard`
- `EmergencyButton`

También se reforzó `OasisSurface` con `Material` interno para soportar campos de entrada correctamente.

## Integración Visual

### Journal
- ambiente: `Bruma`
- tono íntimo, suave y reflexivo
- timeline en tarjetas con métricas emocionales resumidas

### Safety Plan
- ambiente: `Noche Serena`
- cálido, nunca negro puro
- enfoque en contención, aire y acompañamiento

## Arquitectura
Se mantuvo:
- Clean Architecture
- Riverpod
- ODL
- MotionSpec
- LivingCanvas

No se rompió ninguna feature existente.

## Navegación
Se agregó la ruta:
- `/safety-plan`

Accesos:
- botón persistente `No estoy bien`
- CTA dentro de Journal

## Verificación
- `flutter test`: 28/28 pasando
- `flutter analyze --no-fatal-infos --no-fatal-warnings`: sin errores de compilación

Persisten infos heredados del repositorio, no introducidos por Experience 10.

## Capturas
No fue posible adjuntar capturas automáticas en este turno por dos bloqueos técnicos del entorno:
1. no hay browser pages compartidas
2. Flutter Driver screenshot requiere driver extension habilitada y la app actual no la expone

## Recomendaciones para Phase II siguiente
1. Añadir edición inline más rica para contactos y profesionales en Safety Plan.
2. Crear persistencia real para Safety Plan y Journal cuando se habilite backend.
3. Incorporar recordatorios suaves de autocuidado basados en reglas locales, aún sin IA.
4. Añadir onboarding emocional breve para explicar cuándo usar Safety Plan.
5. Preparar una entrada `driver_main.dart` o flujo visual compartido para capturas automatizadas futuras.
