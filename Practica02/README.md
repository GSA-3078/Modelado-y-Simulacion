# 🔁 Práctica 02: Control ON/OFF con Flip-Flop
### 🔬 Control con histéresis mediante lógica secuencial en MATLAB/Simulink

![MATLAB](https://img.shields.io/badge/MATLAB-Análisis-orange?style=for-the-badge&logo=mathworks&logoColor=white)
![Simulink](https://img.shields.io/badge/Simulink-Simulación-red?style=for-the-badge&logo=mathworks&logoColor=white)
![Control](https://img.shields.io/badge/Control-ON%2FOFF-blue?style=for-the-badge)
![Lógica](https://img.shields.io/badge/Lógica-Flip--Flop%20SR-green?style=for-the-badge)

---

## 📌 Descripción

Esta práctica presenta el diseño y la simulación de un **controlador ON/OFF con histéresis** implementado mediante un **flip-flop SR**, aplicado a un sistema dinámico de primer orden como el modelo RC identificado en la práctica anterior.

El controlador compara la salida del proceso con una **referencia (setpoint)** y activa o desactiva la entrada del sistema según el valor de la variable controlada. El flip-flop **memoriza el estado** de la salida, lo que genera una **banda de histéresis** y evita conmutaciones continuas alrededor del setpoint.

---

## 🎯 Objetivo

Implementar y analizar un control ON/OFF con histéresis, utilizando:

- 🧮 Un modelo de primer orden como proceso.
- ⚖️ Comparadores para detectar los límites superior e inferior de la banda.
- 🔁 Un flip-flop SR para memorizar el estado del controlador.
- 🔄 Simulink para simular el lazo cerrado.
- 📈 MATLAB para graficar y analizar la respuesta.

---

# ⚡ Fundamento teórico

## 🔘 Control ON/OFF

El control ON/OFF (de dos posiciones) solo tiene dos estados de salida:

$$
u(t)=
\begin{cases}
U_{max} & \text{(ON)} \\
0 & \text{(OFF)}
\end{cases}
$$

Es simple y económico, pero la variable controlada **oscila alrededor del setpoint** en lugar de estabilizarse exactamente en él.

## 📏 Histéresis

Para evitar que el controlador conmute de forma continua cuando la señal está cerca del setpoint, se define una **banda de histéresis** de ancho `2h`:

$$
y_{inf}=SP-h \qquad\qquad y_{sup}=SP+h
$$

| Condición | Acción |
|---|---|
| `y < SP − h` | Activar salida (**ON**) |
| `y > SP + h` | Desactivar salida (**OFF**) |
| `SP − h ≤ y ≤ SP + h` | **Mantener** el estado anterior |

## 🔁 Flip-Flop SR

El flip-flop SR es un elemento de **memoria de 1 bit**. Se utiliza para conservar el estado dentro de la banda de histéresis.

| S (Set) | R (Reset) | Q (siguiente) | Acción |
|:---:|:---:|:---:|---|
| 0 | 0 | Q anterior | Memoria |
| 1 | 0 | 1 | ON |
| 0 | 1 | 0 | OFF |
| 1 | 1 | — | Prohibido |

En este controlador:

$$
S = (y < SP-h) \qquad\qquad R = (y > SP+h)
$$

Como `y` no puede ser menor que `SP − h` y mayor que `SP + h` al mismo tiempo, la combinación prohibida `S = R = 1` **nunca ocurre**.

## 🧮 Proceso

El sistema controlado es el modelo de primer orden:

$$
G(s)=\frac{K}{\tau s+1}
$$

Con los valores de la práctica anterior (`K = 1`, `τ ≈ 1.034 s`) y una entrada máxima de 5 V:

$$
y_{max}=K\,U_{max}=5\ \text{V}
$$

> ℹ️ Para que el control pueda alcanzar el setpoint, se debe cumplir `SP < K·U_max`.

---

# 🔬 Estructura del lazo de control

```text
                 ┌─────────────┐
   SP ──────────►│ Comparador  │── y < SP−h ──► S ┐
                 │  inferior   │                  │
                 └─────────────┘            ┌─────▼─────┐        ┌───────────┐
                                            │ Flip-Flop │── Q ──►│ ×  U_max  │── u(t)
                 ┌─────────────┐            │    SR     │        └───────────┘     │
   SP ──────────►│ Comparador  │── y > SP+h ─► R ┘      │                          │
                 │  superior   │            └───────────┘                          ▼
                 └──────▲──────┘                                           ┌─────────────┐
                        │                                                  │   Proceso   │
                        │                  y(t)                            │ K/(τs+1)    │
                        └──────────────────────────────────────────────────┤             │
                                                                           └─────────────┘
```

---

# 🧰 Herramientas

| Herramienta | Uso |
|---|---|
| 🟧 **MATLAB** | Parámetros, simulación y graficación |
| 🟥 **Simulink** | Modelo del lazo cerrado |
| 🧱 **Bloques utilizados** | Step / Constant, Compare To Constant o Relational Operator, S-R Flip-Flop, Gain, Transfer Fcn, Scope |

---

# ⚙️ Parámetros de la simulación

| Parámetro | Símbolo | Valor |
|---|---|---|
| Ganancia del proceso | `K` | 1 |
| Constante de tiempo | `τ` | 1.034 s |
| Entrada máxima | `U_max` | 5 V |
| Setpoint | `SP` | ___ V |
| Semibanda de histéresis | `h` | ___ V |
| Tiempo de simulación | `t_sim` | ___ s |

---

# 🧪 Procedimiento

1. Define los parámetros del proceso y del controlador en el *workspace* de MATLAB.
2. Construye el modelo en Simulink:
   - Dos bloques de comparación: uno para `y < SP − h` (entrada **S**) y otro para `y > SP + h` (entrada **R**).
   - Un bloque **S-R Flip-Flop** con la salida `Q`.
   - Una ganancia `U_max` para convertir `Q` (0/1) en la señal de control `u`.
   - Un bloque **Transfer Fcn** con el modelo del proceso.
   - La salida del proceso retroalimenta a los comparadores.
3. Ejecuta la simulación y observa en el *Scope* las señales `y(t)`, `u(t)` y `Q(t)`.
4. Repite la simulación con diferentes valores de `h` y compara los resultados.
5. Calcula el **periodo de oscilación** y la **amplitud** de la respuesta en estado estable.

---

# 📊 Resultados

| Caso | Semibanda `h` | Amplitud de oscilación | Periodo | Conmutaciones |
|---|---|---|---|---|
| 1 | ___ V | ___ V | ___ s | ___ |
| 2 | ___ V | ___ V | ___ s | ___ |
| 3 | ___ V | ___ V | ___ s | ___ |

### 🔍 Efecto de la histéresis

| Banda de histéresis | Oscilación del sistema | Conmutaciones |
|---|---|---|
| Pequeña | Menor amplitud | Muchas (más desgaste en un actuador real) |
| Grande | Mayor amplitud | Pocas |

---

# ✅ Conclusiones

- El controlador ON/OFF mantiene la salida **oscilando alrededor del setpoint**, sin alcanzar un valor exactamente constante.
- El **flip-flop SR** permite memorizar el estado de la salida, lo que implementa la histéresis de forma natural.
- Una banda **más estrecha** reduce la amplitud de la oscilación, pero aumenta el número de conmutaciones.
- Una banda **más amplia** reduce las conmutaciones, pero aumenta el error respecto al setpoint.
- Este tipo de control es útil en sistemas donde se tolera cierta oscilación, y su limitación motiva el estudio de controladores **P, PI y PID**.

---

# 📁 Estructura de la práctica

```text
Practica02/
│
├── img/            → Gráficas y resultados
├── src/            → Scripts de MATLAB y modelo de Simulink
└── README.md       → Documentación de la práctica
```
**GSA-3078**

📚 Asignatura: Modelado y Simulación
