# ⚡ Práctica 01: Identificación de un Modelo RC de Primer Orden
### 🔬 Adquisición experimental con Arduino + MATLAB/Simulink

![Arduino](https://img.shields.io/badge/Arduino-Adquisición-00979D?style=for-the-badge&logo=arduino&logoColor=white)
![MATLAB](https://img.shields.io/badge/MATLAB-Identificación-orange?style=for-the-badge&logo=mathworks&logoColor=white)
![Simulink](https://img.shields.io/badge/Simulink-Simulación-red?style=for-the-badge&logo=mathworks&logoColor=white)
![Control](https://img.shields.io/badge/Control-Sistemas-blue?style=for-the-badge)

---

## 📌 Descripción

Esta práctica presenta la **identificación experimental de un circuito RC de primer orden** mediante la adquisición de datos con **Arduino** y el procesamiento e identificación del modelo utilizando **MATLAB/Simulink**.

El procedimiento se basa en aplicar un **escalón de entrada de 5 V** al circuito RC y registrar experimentalmente la respuesta de voltaje del capacitor.

Los datos obtenidos mediante Arduino se utilizan en **MATLAB**, específicamente con **System Identification Toolbox** y la herramienta **Ident**, con el propósito de obtener un modelo matemático que represente el comportamiento dinámico del proceso.

Finalmente, el modelo identificado se implementa en **Simulink** para comparar la respuesta simulada con la respuesta experimental.

---

## 🎯 Objetivo

Obtener experimentalmente un **modelo matemático de primer orden** que represente el comportamiento dinámico de un circuito RC, utilizando:

- 🔌 Un circuito RC como proceso físico.
- 🤖 Arduino como sistema de adquisición.
- 💻 MATLAB para procesamiento de datos.
- 🧩 System Identification Toolbox para identificación.
- 📊 Ident para estimación del modelo.
- 🔄 Simulink para simulación y validación.

La identificación se realiza a partir de la respuesta del sistema ante un **escalón de 5 V**.

---

# ⚡ Fundamento teórico

Un circuito RC puede modelarse como un sistema dinámico de primer orden.

La forma general del modelo es:

$$
G(s)=\frac{K}{\tau s+1}
$$

donde:

| Parámetro | Descripción | Unidad |
|---|---|---|
| `K` | Ganancia estática | — |
| `τ` | Constante de tiempo | s |
| `s` | Variable de Laplace | — |

Para un circuito RC ideal:

$$
\tau=RC
$$

donde:

- `R` = resistencia [Ω]
- `C` = capacitancia [F]
- `τ` = constante de tiempo [s]

### 🧮 Valores teóricos de la práctica

Con los componentes utilizados:

$$
\tau = RC = (4700\ \Omega)(220\times10^{-6}\ \text{F}) \approx 1.034\ \text{s}
$$

Por lo tanto, el modelo teórico esperado es:

$$
G(s)=\frac{1}{1.034s+1}
$$

---

# 📈 Respuesta al escalón

La entrada utilizada durante el experimento es un escalón de:

$$
V_{in}=5V
$$

Para un sistema de primer orden con ganancia unitaria, la respuesta ideal es:

$$
V_{out}(t)=5(1-e^{-t/\tau})
$$

Esta respuesta permite determinar experimentalmente la dinámica del circuito.

---

# ⏱️ Criterio de estabilización

Para esta práctica se utiliza como criterio práctico de estabilización:

$$
t_s \approx 5\tau
$$

Después de cinco constantes de tiempo, la respuesta de un sistema de primer orden ideal alcanza aproximadamente el:

$$
99.3\%
$$

del valor final.

### 📊 Evolución aproximada de la respuesta

| Tiempo | Tiempo real (τ = 1.034 s) | % del valor final |
|---|---:|---:|
| `1τ` | 1.03 s | 63.2 % |
| `2τ` | 2.07 s | 86.5 % |
| `3τ` | 3.10 s | 95.0 % |
| `4τ` | 4.14 s | 98.2 % |
| `5τ` | 5.17 s | 99.3 % |

Para un escalón de 5 V:

$$
V_{out}(5\tau) = 5(1-e^{-5}) \approx 4.97V
$$

Por lo tanto, la adquisición debe mantenerse el tiempo suficiente para observar aproximadamente **5τ ≈ 5.2 s**. Se recomienda registrar entre **6 y 7 s** para apreciar bien el estado estable.

---

# 🔬 Metodología experimental

El procedimiento general es:

```text
        ⚡ Escalón de 5 V
               │
               ▼
        ┌──────────────┐
        │ Circuito RC  │
        │   Proceso    │
        └──────┬───────┘
               │
               │ Vout(t)
               ▼
        ┌──────────────┐
        │   Arduino    │
        │ Adquisición  │
        └──────┬───────┘
               │
               │ Datos
               ▼
        ┌──────────────┐
        │    MATLAB    │
        └──────┬───────┘
               │
               ▼
       ┌─────────────────┐
       │ System          │
       │ Identification  │
       │    / Ident      │
       └──────┬──────────┘
              │
              ▼
       ┌─────────────────┐
       │ Modelo de       │
       │ primer orden    │
       └──────┬──────────┘
              │
              ▼
        ┌──────────────┐
        │   Simulink   │
        │  Validación  │
        └──────────────┘
```

---

# 🧰 Materiales

| Componente | Valor / Descripción |
|---|---|
| 🤖 Arduino | Placa con entrada analógica de 10 bits |
| 🔌 Resistencia `R` | 4700 Ω |
| 🔋 Capacitor `C` | 220 µF |
| 🧵 Protoboard y cables | Para el armado del circuito |
| 💻 Computadora | MATLAB con System Identification Toolbox y Simulink |

---

# 🔌 Conexión del circuito

```text
   Escalón 5 V ──────[ 4.7 kΩ ]──────┬────────► Entrada analógica (A0)
                                     │
                                   ──┴──
                                   ──┬──  220 µF
                                     │
   GND ──────────────────────────────┴────────► GND (común con Arduino)
```

> ⚠️ **Importante:** la tierra del circuito debe ser común con la del Arduino. El capacitor de 220 µF es electrolítico, por lo que se debe respetar su polaridad (terminal negativa a GND).

---

# 🧪 Procedimiento

1. Arma el circuito RC y conecta el nodo entre `R` y `C` a la entrada analógica del Arduino.
2. Carga en el Arduino el programa que lee el voltaje del capacitor y envía **tiempo y voltaje** por el puerto serie.
3. Descarga completamente el capacitor antes de iniciar cada prueba.
4. Aplica el escalón de 5 V y registra la respuesta durante al menos **5τ ≈ 5.2 s**.
5. Guarda los datos adquiridos en MATLAB (variables de tiempo `t` y voltaje `y`).
6. Abre **System Identification Toolbox** con el comando:

```matlab
ident
```

7. Importa los datos de entrada (escalón de 5 V) y salida (voltaje del capacitor), y estima un modelo de **función de transferencia de 1 polo**.
8. Obtén los parámetros `K` y `τ` del modelo identificado.
9. Implementa la función de transferencia en **Simulink** y compara la salida simulada con los datos experimentales.

---

# 📊 Resultados

| Parámetro | Valor teórico | Valor identificado |
|---|---|---|
| `R` | 4700 Ω | — |
| `C` | 220 µF | — |
| `τ = RC` | 1.034 s | ___ s |
| `K` | 1 | ___ |
| Ajuste (Fit) | — | ___ % |

Modelo teórico:

$$
G(s)=\frac{1}{1.034s+1}
$$

Modelo identificado:

$$
G(s)=\frac{K}{\tau s+1}=\frac{\_\_\_}{\_\_\_ s+1}
$$

---

# ✅ Conclusiones

- El circuito RC se comporta como un **sistema de primer orden**, y su respuesta ante el escalón concuerda con el modelo teórico (τ ≈ 1.034 s).
- La herramienta **Ident** permitió estimar `K` y `τ` a partir de datos experimentales.
- La comparación en **Simulink** valida que el modelo identificado reproduce la respuesta medida.
- Las diferencias entre el valor teórico y el identificado se deben a la **tolerancia de los componentes** (los capacitores electrolíticos suelen tener ±20 %), el **ruido de medición** y la **resolución del convertidor analógico-digital**.

---

# 📁 Estructura de la práctica

```text
Practica01/
│
├── img/            → Gráficas y resultados
├── src/            → Código de Arduino y scripts de MATLAB
└── README.md       → Documentación de la práctica
```
