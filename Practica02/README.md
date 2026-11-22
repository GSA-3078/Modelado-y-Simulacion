# ⚡🔥 Control ON/OFF: Circuito RC y Horno
### 🔬 Implementación con Arduino + MATLAB/Simulink e identificación de la función de transferencia

![Arduino](https://img.shields.io/badge/Arduino-Control%20y%20adquisición-00979D?style=for-the-badge&logo=arduino&logoColor=white)
![MATLAB](https://img.shields.io/badge/MATLAB-Análisis-orange?style=for-the-badge&logo=mathworks&logoColor=white)
![Simulink](https://img.shields.io/badge/Simulink-Modelado-red?style=for-the-badge&logo=mathworks&logoColor=white)
![Control](https://img.shields.io/badge/Control-ON%2FOFF-blue?style=for-the-badge)

---

## 📌 Descripción

Este proyecto presenta el diseño e implementación de un **controlador ON/OFF con histéresis** aplicado a dos sistemas de primer orden:

- ⚡ **Circuito RC:** la variable de proceso es la tensión del capacitor.
- 🔥 **Horno eléctrico:** la variable de proceso es la temperatura medida con un sensor **LM35**.

En ambos casos, Arduino funciona como plataforma de control y adquisición, y **MATLAB/Simulink** se utiliza para implementar la lógica de control, registrar los datos e **identificar la función de transferencia** del proceso a partir de los ciclos de carga/descarga (RC) o calentamiento/enfriamiento (horno).

La variable medida se compara con dos niveles de operación:

- **HL (High Level):** límite superior de conmutación.
- **LL (Low Level):** límite inferior de conmutación.

| Estado | RC | Horno |
|---|---|---|
| 🟢 **ON** (al llegar a LL) | Se carga el capacitor | Se enciende el foco (calienta) |
| 🔴 **OFF** (al llegar a HL) | Se descarga el capacitor | Se encienden la Peltier y el extractor (enfría) |

Cuando la señal se encuentra entre ambos umbrales, el controlador **conserva su estado anterior** mediante un **biestable SR**. Esto genera una banda de histéresis que evita conmutaciones innecesarias.

**Importante:** el sistema no utiliza una referencia ni un punto de suma para calcular el error. La decisión de control se basa directamente en los umbrales HL y LL.

---

## 🎯 Objetivo

Implementar y analizar un controlador ON/OFF con histéresis, y obtener a partir de los datos experimentales la **función de transferencia de primer orden** de cada proceso.

El proyecto integra:

- 🔌 Un circuito RC y un horno como procesos físicos.
- 🌡️ Un sensor LM35 para la temperatura del horno.
- 🤖 Arduino para el control y la adquisición de señales.
- 📏 Comparadores de nivel superior e inferior HL/LL.
- 🔄 Un biestable SR como memoria del controlador.
- 🧮 Un filtro de promedio móvil (horno).
- 💻 MATLAB para el análisis de datos e identificación con **Ident**.
- 🧩 Simulink para la implementación del sistema de control.

---

## 🧱 Arquitectura del sistema

```text
                  ┌───────────────────────┐
                  │   Comparadores HL/LL  │
                  │                       │
                  │  S: y(t) >= HL        │
                  │  R: y(t) <= LL        │
                  └───────────┬───────────┘
                              │
                              ▼
                  ┌───────────────────────┐
                  │   Biestable SR        │
                  │                       │
                  │  Memoria de estado    │
                  │  Q / !Q               │
                  └───────────┬───────────┘
                              │ u(t)
                              ▼
                  ┌───────────────────────┐
                  │   Proceso             │
                  │   RC  /  Horno        │
                  │  G(s) = K/(τs + 1)    │
                  └───────────┬───────────┘
                              │
                              ▼
                  ┌───────────────────────┐
                  │   Salida medida y(t)  │
                  │  Analog Read (+filtro)│
                  └───────────┬───────────┘
                              │
                              │ Retroalimentación
                              └───────────────►
                                  HL / LL
```

---

## ⚡ Fundamento teórico

### 1. Modelo de primer orden

Ambos procesos se aproximan con:

$$
G(s)=\frac{K}{\tau s+1}
$$

| Parámetro | Circuito RC | Horno |
|---|---|---|
| Salida `y(t)` | Tensión del capacitor [V] | Temperatura [°C] |
| Entrada `u(t)` | 0 / 5 V | Foco OFF / ON (0 / 1) |
| `K` | ≈ 1 | °C que sube el horno con el foco encendido |
| `τ` | `τ = RC` (≈ 1 s) | Constante de tiempo térmica (minutos) |

### 2. Respuesta dinámica

**Circuito RC**

Carga (capacitor inicialmente descargado):

$$
V_C(t)=V_s\left(1-e^{-t/\tau}\right)
$$

Descarga desde un voltaje inicial $V_0$:

$$
V_C(t)=V_0e^{-t/\tau}
$$

**Horno**

Calentamiento desde una temperatura inicial $T_0$:

$$
T(t)=T_0+K\left(1-e^{-t/\tau}\right)
$$

El enfriamiento se realiza con una celda **Peltier** y un **extractor**, por lo que la bajada de temperatura **no es simétrica** a la subida: el horno calienta más rápido de lo que enfría.

---

## 🔁 Lógica del controlador ON/OFF

| Condición | Biestable SR | Acción |
|---|---|---|
| $y(t)\geq HL$ | Set → `Q = 1` | OFF (descarga / enfría) |
| $LL<y(t)<HL$ | Memoria | Sin cambio |
| $y(t)\leq LL$ | Reset → `Q = 0` | ON (carga / calienta) |

$$
u(t)=
\begin{cases}
\text{ON}, & y(t)\leq LL\\
u(t^-), & LL<y(t)<HL\\
\text{OFF}, & y(t)\geq HL
\end{cases}
$$

### Umbrales utilizados

| Sistema | HL | LL | Banda $H = HL - LL$ |
|---|---|---|---|
| Circuito RC | 3 V | 1 V | 2 V |
| Horno | 40 °C | 31 °C | 9 °C |

---

## 🔌 Implementación con Arduino

### Conexiones

**Circuito RC**

| Elemento | Pin Arduino |
|---|---|
| Resistencia R (excitación) | `10` |
| Nodo R–C (tensión del capacitor) | `A0` |
| Capacitor C | `GND` |

**Horno**

| Elemento | Pin Arduino | Señal del biestable |
|---|---|---|
| LM35 (Vout) | `A0` | — |
| Relé foco | `10` | `Q` |
| Relé Peltier + ventiladores | `11` | `!Q` |
| Relé extractor | `12` | `!Q` |

> 💡 Los relés del horno son **activos en LOW**. Por eso el foco se conecta a `Q` (calienta cuando `Q = 0`) y la Peltier y el extractor a `!Q` (enfrían cuando `!Q = 0`). Así se manejan los tres relés **sin bloques NOT**.

### Conversión de la lectura analógica

ADC de 10 bits con referencia de 5 V:

$$
V_{in}=\frac{5N}{1023}
$$

Para el LM35 (10 mV/°C):

$$
T=\frac{500N}{1023}
$$

Cada paso del ADC equivale a ≈ 0.49 °C, por lo que en el horno se agrega un **filtro de promedio móvil de 5 muestras**:

$$
T_f[k]=\frac{T[k]+T[k-1]+T[k-2]+T[k-3]+T[k-4]}{5}
$$

---

## 💻 Modelo en Simulink

| Bloque | Circuito RC | Horno |
|---|---|---|
| Arduino IO Setup | `a`, `COM4` | `a`, `COM4` |
| Real-Time Pacer | Speedup = 1 | Speedup = 1 |
| Arduino Analog Read | Pin `0` | Pin `0` |
| Gain (conversión) | `5/1023` | `500/1023` |
| Filtro promedio móvil | — | 4 × `Unit Delay` (IC = `T0`) + `Sum +++++` + Gain `1/5` |
| Constant HL / LL | `3` / `1` | `40` / `31` |
| Relational Operator | `>=` (S) y `<=` (R) | `>=` (S) y `<=` (R) |
| S-R Flip-Flop | Simulink Extras | Simulink Extras |
| Arduino Digital Write | `!Q` → Pin `10` | `Q` → Pin `10`, `!Q` → Pins `11` y `12` |
| Gain (registro de entrada) | `5` | `1` |
| Bus Creator → To Workspace | `out.data` | `out.data` |
| Scope | Salida | Temperatura + HL + LL (Mux) |

Registro en `out.data`:

| Señal | Circuito RC | Horno |
|---|---|---|
| `signal1` | Entrada `u(t)` (0 / 5 V) | Foco encendido (0 / 1) |
| `signal2` | Tensión del capacitor | Temperatura filtrada |

Configuración del modelo: Solver **Fixed-step**, Stop Time `inf`.

---

## ⚙️ Configuración (`config.m`)

**Circuito RC**

```matlab
%% Declarar PATH con funciones de Simulink
addpath('C:\Users\Gel98\OneDrive\Escritorio\MATLAP\ArduinoIO\simulink')

%% Declarar Arduino
delete(instrfind({'Port'},{'COM4'}))
a = myarduino('COM4');

%% Configuracion de puerto
pinMode(a,10,'output');
```

**Horno**

```matlab
%% Declarar PATH con funciones de Simulink
addpath('C:\Users\Gel98\OneDrive\Escritorio\MATLAP\ArduinoIO\simulink')

%% Declarar Arduino
delete(instrfind({'Port'},{'COM4'}))
a = myarduino('COM4');

%% Configuracion de puertos (reles activos en LOW -> 0 = ON, 1 = OFF)
% Primero HIGH y luego output, para que no hagan click al configurar
for p = [10 11 12]          % 10 Foco | 11 Peltier + ventiladores | 12 Extractor
    digitalWrite(a,p,1);
    pinMode(a,p,'output');
    digitalWrite(a,p,1);
end

%% Temperatura inicial (Initial condition de los Unit Delay del filtro)
T0 = analogRead(a,0)*500/1023;
fprintf('Listo. Temperatura inicial: %.1f °C\n', T0);
```

**StopFcn del horno** (*Model Properties → Callbacks → StopFcn*), para apagar los relés al detener:

```matlab
digitalWrite(a,10,1); digitalWrite(a,11,1); digitalWrite(a,12,1);
```

---

## 📊 Análisis de datos (`analisis.m`)

**Circuito RC**

```matlab
%% Limites usados en el modelo
HL = 3;     % V
LL = 1;     % V

%DATOS adquiridos de la entrada del proceso
t = out.data.signal1.Time;
entrada = out.data.signal1.Data;

%DATOS adquiridos de la salida del proceso
salida = out.data.signal2.Data;

%Graficacion del proceso
plot(t,entrada,'r',t,salida,'b')
hold on
yline(HL,'--k'); yline(LL,'--g');
hold off
grid("on")
title("Control ON/OFF de un sistema RC")
xlabel("Tiempo (s)")
ylabel("Voltaje (V)")
legend("Entrada","Salida","HL","LL")

%ident   % abre la herramienta de identificacion
```

**Horno**

```matlab
%% Limites usados en el modelo
HL = 40;    % °C
LL = 31;    % °C

%DATOS adquiridos de la entrada del proceso (foco: 1 = ON)
t = out.data.signal1.Time;
entrada = squeeze(out.data.signal1.Data);

%DATOS adquiridos de la salida del proceso (temperatura filtrada)
salida = squeeze(out.data.signal2.Data);

%Entrada escalada: 0 -> LL , 1 -> HL (solo para graficar)
entrada_esc = LL + entrada*(HL - LL);

%Graficacion del proceso
plot(t,entrada_esc,'r',t,salida,'b')
hold on
yline(HL,'--k'); yline(LL,'--g');
hold off
grid("on")
ylim([LL-3, HL+3])
title("Respuesta del horno con control ON/OFF")
xlabel("Tiempo (s)")
ylabel("Temperatura (°C)")
legend("Entrada (foco)","Temperatura","HL","LL")

%Datos para identificacion (quitar la temperatura inicial)
salida_ident = salida - salida(1);

%ident   % abre la herramienta de identificacion
```

---

## 🧮 Identificación de la función de transferencia

Los ciclos ON/OFF contienen subidas y bajadas exponenciales, por lo que pueden utilizarse para estimar el modelo de primer orden:

1. Ejecutar el `analisis.m` correspondiente.
2. Abrir **Ident** e importar: *Import data → Time domain data*
   - Input: `entrada`
   - Output: `salida` (RC) o `salida_ident` (horno)
   - Start time: `0`
   - Sample time: paso del solver
3. Estimar: *Estimate → Process Models → P1* (en el horno, probar también **P1D**, con retardo).
4. Revisar el porcentaje de ajuste (*Model Output*).
5. Validar el modelo en Simulink con un bloque **Transfer Fcn** alimentado con la misma señal ON/OFF.

$$
G(s)=\frac{K}{\tau s+1}
$$

> 💡 En el horno, la subida (foco) y la bajada (Peltier + extractor) tienen dinámicas diferentes. Puede identificarse un modelo global, o bien identificar por separado el **tramo de calentamiento** y el **tramo de enfriamiento**.

---

## 🧪 Metodología experimental

### Etapa 1. Preparación

1. Montar el circuito (RC u horno) y verificar las conexiones.
2. Cargar el sketch `adiosrv` de ArduinoIO al Arduino.
3. En el horno, verificar que la parte de **127 V AC** y la de **12 V** estén aisladas del protoboard.

### Etapa 2. Configuración

1. Ejecutar el `config.m` correspondiente.
2. Ajustar HL, LL y las ganancias del modelo según la tabla.
3. Verificar que $HL > LL$.

### Etapa 3. Ejecución

1. Presionar **Run** en Simulink.
2. Dejar correr varios ciclos completos (segundos en el RC, varios minutos en el horno).
3. Detener la simulación.

### Etapa 4. Análisis

1. Ejecutar el `analisis.m`.
2. Identificar los instantes de conmutación y los ciclos de subida y bajada.
3. Identificar la función de transferencia con **Ident**.
4. Comparar la respuesta experimental con el modelo.

---

## 📊 Resultados esperados

- Una señal de control con dos estados: ON y OFF.
- Variaciones exponenciales de la salida entre LL y HL.
- En el horno, un **sobrepaso ligero** por encima de HL y por debajo de LL debido a la inercia térmica.
- En el horno, un **calentamiento más rápido que el enfriamiento**.
- Un modelo de primer orden $G(s)=K/(\tau s+1)$ para cada proceso.

---

## 📈 Indicadores de evaluación

| Indicador | Descripción |
|---|---|
| Tiempo de subida | Tiempo para ir de LL a HL |
| Tiempo de bajada | Tiempo para ir de HL a LL |
| Frecuencia de conmutación | Cambios de estado por unidad de tiempo |
| Banda de histéresis | $HL - LL$ |
| Valor máximo / mínimo | Sobrepaso respecto a HL y LL |
| Ganancia `K` | Obtenida con Ident |
| Constante de tiempo `τ` | Obtenida con Ident |

---

## 📁 Estructura del proyecto

```text
Control_ON_OFF/
│
├── README.md
│
├── RC/
│   ├── config.m
│   ├── analisis.m
│   └── modelo_on_off_rc.slx
│
├── Horno/
│   ├── config.m
│   ├── analisis.m
│   └── modelo_on_off_horno.slx
│
└── img/
    ├── esquematico.png
    ├── diagrama_simulink.png
    └── respuesta.png
```

---

## 📚 Conclusión

El controlador ON/OFF con histéresis permite mantener la variable de proceso dentro de una banda definida por HL y LL, utilizando únicamente comparadores y un biestable SR como memoria.

Aplicado al circuito RC y al horno, el mismo esquema de control muestra cómo cambia el comportamiento según la dinámica del proceso: el RC conmuta en segundos, mientras que el horno lo hace en minutos y presenta sobrepasos por su inercia térmica. Los ciclos registrados permiten además identificar la función de transferencia de primer orden de cada sistema.

---

### 👨‍💻 Tecnologías utilizadas

- Arduino
- MATLAB
- Simulink
- Circuito RC
- Sensor LM35
- Relés, celda Peltier y foco
- Control ON/OFF con histéresis
- System Identification Toolbox (Ident)

**Proyecto educativo de control automático y sistemas dinámicos.**
