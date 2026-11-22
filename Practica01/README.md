# ⚡🔥 Identificación de Sistemas de Primer Orden: Circuito RC y Horno
### 🔬 Respuesta al escalón con Arduino + MATLAB/Simulink

![Arduino](https://img.shields.io/badge/Arduino-Adquisición-00979D?style=for-the-badge&logo=arduino&logoColor=white)
![MATLAB](https://img.shields.io/badge/MATLAB-Identificación-orange?style=for-the-badge&logo=mathworks&logoColor=white)
![Simulink](https://img.shields.io/badge/Simulink-Simulación-red?style=for-the-badge&logo=mathworks&logoColor=white)
![Control](https://img.shields.io/badge/Control-Sistemas-blue?style=for-the-badge)

---

## 📌 Descripción

Este proyecto presenta la **identificación experimental de dos sistemas de primer orden** mediante la adquisición de datos con **Arduino** y el procesamiento en **MATLAB/Simulink**:

- ⚡ **Circuito RC:** se aplica un escalón de **5 V** y se registra el voltaje del capacitor.
- 🔥 **Horno eléctrico:** se enciende un foco a máxima potencia mediante un relé y se registra la temperatura con un sensor **LM35**.

En ambos casos se utiliza el **mismo modelo de Simulink**, cambiando únicamente la escala de la medición. Los datos se procesan con la herramienta **Ident** del **System Identification Toolbox** para obtener la función de transferencia de cada sistema.

---

## 🎯 Objetivo

Obtener experimentalmente un **modelo matemático de primer orden** de un circuito RC y de un horno, utilizando:

- 🔌 Un circuito RC y un horno como procesos físicos.
- 🌡️ Un sensor LM35 para medir la temperatura del horno.
- 🤖 Arduino como sistema de adquisición y actuación.
- 💻 MATLAB para el procesamiento de datos.
- 📊 Ident para la estimación del modelo.
- 🔄 Simulink para la adquisición y la validación.

---

# 📐 Fundamento teórico

Ambos sistemas pueden modelarse como sistemas de primer orden:

$$
G(s)=\frac{K}{\tau s+1}
$$

| Parámetro | Circuito RC | Horno |
|---|---|---|
| Entrada | Escalón de 5 V | Foco apagado → encendido (0 → 1) |
| Salida | Voltaje del capacitor [V] | Temperatura [°C] |
| `K` | Ganancia estática (≈ 1) | °C que sube el horno con el foco encendido |
| `τ` | `τ = RC` [s] | Constante de tiempo térmica [s] |
| Valor inicial | 0 V | Temperatura ambiente `T₀` |

> 💡 El horno **no inicia en cero**, sino en `T₀`. Por eso, antes de identificar, se le resta `T₀` a la salida.

---

# 📈 Respuesta al escalón

**Circuito RC:**

$$
V_{out}(t)=5\left(1-e^{-t/\tau}\right)
$$

**Horno:**

$$
T(t)=T_0+K\left(1-e^{-t/\tau}\right)
$$

---

# ⏱️ Criterio de estabilización

$$
t_s \approx 5\tau
$$

| Tiempo | % del valor final |
|---|---:|
| `1τ` | 63.2 % |
| `2τ` | 86.5 % |
| `3τ` | 95.0 % |
| `4τ` | 98.2 % |
| `5τ` | 99.3 % |

> ⚠️ El circuito RC se estabiliza en **segundos**; el horno, en **varios minutos**. La adquisición debe mantenerse hasta observar aproximadamente **5τ**.

---

# 🔌 Conexiones

**Circuito RC**

| Elemento | Pin Arduino |
|---|---|
| Resistencia R (entrada) | `10` |
| Nodo R–C (Vout) | `A0` |
| Capacitor C | `GND` |

**Horno**

| Elemento | Pin Arduino | Nota |
|---|---|---|
| LM35 (Vout) | `A0` | +Vs a 5V, GND a GND |
| Relé foco | `10` | Activo en LOW |
| Relé Peltier + ventiladores | `11` | Apagado durante la prueba |
| Relé extractor | `12` | Apagado durante la prueba |

> 💡 Los relés del horno son **activos en LOW**: escribir `0` los **enciende** y `1` los **apaga**.

---

# 🧩 Modelo en Simulink

| Bloque | Circuito RC | Horno | Función |
|---|---|---|---|
| Arduino IO Setup | `a`, `COM4` | `a`, `COM4` | Comunicación con Arduino |
| Real-Time Pacer | Speedup = 1 | Speedup = 1 | Tiempo real |
| Constant | `0` → `1` | `0` | Escalón de entrada |
| Arduino Digital Write | Pin `10` | Pin `10` | Carga del capacitor / relé del foco |
| Gain (entrada) | `5` | `1` | Entrada registrada |
| Arduino Analog Read | Pin `0` | Pin `0` | Lectura de Vout / LM35 |
| Gain (salida) | `5/1023` | `500/1023` | Conversión a V / °C |
| Bus Creator → To Workspace | `out.data` | `out.data` | `signal1` = entrada, `signal2` = salida |
| Scope | — | — | Visualización en tiempo real |

**Conversión del LM35** (10 mV/°C, ADC de 10 bits a 5 V):

$$
T = N\cdot\frac{500}{1023}
$$

---

# ⚙️ Configuración (`config.m`)

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
for p = [10 11 12]          % 10 Foco | 11 Peltier | 12 Extractor
    digitalWrite(a,p,1);
    pinMode(a,p,'output');
    digitalWrite(a,p,1);
end
```

---

# 📊 Análisis de datos (`analisis.m`)

**Circuito RC**

```matlab
%DATOS adquiridos de la entrada del proceso
t = out.data.signal1.Time;
entrada = out.data.signal1.Data;

%DATOS adquiridos de la salida del proceso
salida = out.data.signal2.Data;

%Graficacion del proceso
plot(t,entrada,'r',t,salida,'b')
grid("on")
title("Respuesta al escalón de un sistema RC")
xlabel("Tiempo (s)")
ylabel("Voltaje (V)")
legend("Entrada","Salida")

%ident   % abre la herramienta de identificacion
```

**Horno**

```matlab
%DATOS adquiridos de la entrada del proceso
t = out.data.signal1.Time;
entrada = 1 - out.data.signal1.Data;   % rele activo en LOW: 0 en el pin = foco ON

%DATOS adquiridos de la salida del proceso
salida = out.data.signal2.Data;

%Quitar la temperatura ambiente para identificar
salida_ident = salida - salida(1);

%Graficacion del proceso
plot(t,entrada*max(salida),'r',t,salida,'b')
grid("on")
title("Respuesta al escalón del horno")
xlabel("Tiempo (s)")
ylabel("Temperatura (°C)")
legend("Entrada (foco)","Temperatura")

%ident   % abre la herramienta de identificacion
```

---

# 🔬 Metodología experimental

```text
        ⚡🔥 Escalón de entrada
               │
               ▼
        ┌─────────────┐
        │ Circuito RC │
        │  / Horno    │
        └──────┬──────┘
               │
               │ Vout(t) / T(t)
               ▼
        ┌─────────────┐
        │   Arduino   │
        │ Adquisición │
        └──────┬──────┘
               │
               │ Datos
               ▼
        ┌─────────────┐
        │    MATLAB   │
        └──────┬──────┘
               │
               ▼
       ┌─────────────────┐
       │ System          │
       │ Identification  │
       │      / Ident    │
       └──────┬──────────┘
              │
              ▼
       ┌─────────────────┐
       │ Modelo de       │
       │ primer orden    │
       └──────┬──────────┘
              │
              ▼
        ┌─────────────┐
        │   Simulink  │
        │  Validación │
        └─────────────┘
```

---

# 🧪 Procedimiento

1. Cargar el sketch `adiosrv` de ArduinoIO al Arduino.
2. Ejecutar el `config.m` correspondiente (RC u horno).
3. Abrir el modelo de Simulink y ajustar las ganancias según la tabla.
4. Configurar el Solver en **Fixed-step** y el Stop Time en `inf`.
5. Presionar **Run** y aplicar el escalón:
   - **RC:** cambiar la Constant de `0` a `1`.
   - **Horno:** la Constant en `0` enciende el foco desde el inicio.
6. Esperar a que la salida se estabilice (≈ 5τ).
7. Detener la simulación y ejecutar el `analisis.m` correspondiente.
8. En **Ident**: *Import data → Time domain data*
   - Input: `entrada`
   - Output: `salida` (RC) o `salida_ident` (horno)
   - Sample time: el paso del solver
9. Estimar un modelo **Process Model → P1** (en el horno, probar también **P1D**, con retardo).
10. Validar el modelo en Simulink con un bloque **Transfer Fcn**.

---

# ⚠️ Recomendaciones

- 📂 Si los bloques aparecen como **"arduino_io_lib not found"**, ejecutar primero el `addpath` del `config.m`.
- 🔌 En el horno, escribir `HIGH` **antes** de `pinMode` evita que los relés se activen al iniciar.
- 🌡️ No dejar el horno sin supervisión mientras el foco está encendido.
- ⚡ El foco trabaja con **127 V AC**: mantener esa parte aislada del protoboard.
- 📉 Restar la temperatura inicial `T₀` antes de identificar el horno; de lo contrario, la ganancia `K` sale incorrecta.
