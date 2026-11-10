# 🤖 Micro-Agente Autónomo: Aisha Greyrat (Ale)
**Rol Oficial:** Asistente Personal de Ale: Preparación Física (Vóley Líbero) & Taller  
**Repositorio Independiente:** `Aleh313/agente-aisha-ale`  
**Ecosistema:** Electronicat (Catamarca, Argentina)

---

## 🎯 1. Propósito y Misión Operativa
Acompañamiento integral de Ale: plan de entrenamiento en casa (17-25 min Full Body), cuidado de articulaciones para A1/A2 y soporte de taller.

Este repositorio es un **microsistema 100% independiente**. Puede clonarse, modificarse y desplegarse de manera aislada sin depender del servidor central monolítico.

---

## ⚙️ 2. Arquitectura de Archivos y Funcionamiento
Para que cualquier modelo de IA o desarrollador trabaje en esta carpeta:

- **`db.json`**: Base de datos local y persistente exclusiva de este agente. Almacena en `db.json` sesiones de entrenamiento, registro de fatiga física y recordatorios personales.
- **`agente.js`**: Lógica de inicialización autónoma, bucle de ejecución y conexión al bus de eventos.
- **`PROMPT_ENTRENAMIENTO.md`**: Cerebro del agente, bibliografía técnica inyectada y reglas operativas inquebrantables.
- **`SKILLS.md`**: Capacidades y herramientas específicas asignadas a su rol.
- **`config.json`**: Metadatos de configuración, sector asignado y pares de comunicación.
- **`memoria/MEMORIA_ACTIVIDAD.md`**: Registro inmutable de contexto histórico y última mejora implementada.

---

## 🛡️ 3. Reglas de Oro para IAs y Desarrolladores que Modifiquen este Agente
1. **No mezclar bases de datos:** Este agente solo debe leer y escribir en su propio `db.json` local. Nunca intentes acceder directamente a bases de otros agentes; toda interacción entre agentes se realiza mediante eventos en el bus.
2. **Respetar la personalidad y rol:** Consulta siempre `PROMPT_ENTRENAMIENTO.md` antes de generar código o respuestas.
3. **Persistir cada mejora:** Cada vez que resuelvas un bug, agregues una regla o actualices datos, debes registrar la entrada con fecha en `memoria/MEMORIA_ACTIVIDAD.md`.
4. **Commits atómicos y claros:** Al hacer push a este repositorio, escribe mensajes descriptivos del cambio realizado en el micro-agente.
