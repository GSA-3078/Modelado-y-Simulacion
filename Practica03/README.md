# ⚡🔥 Control Proporcional (P): Circuito RC y Horno
### 🔬 Implementación con Arduino + MATLAB/Simulink

![Arduino](https://img.shields.io/badge/Arduino-Control%20y%20adquisición-00979D?style=for-the-badge&logo=arduino&logoColor=white)
![MATLAB](https://img.shields.io/badge/MATLAB-Análisis-orange?style=for-the-badge&logo=mathworks&logoColor=white)
![Simulink](https://img.shields.io/badge/Simulink-Modelado-red?style=for-the-badge)
![Control](https://img.shields.io/badge/Control-Proporcional%20(P)-blue?style=for-the-badge)

---

## 📌 1. Descripción

Este proyecto presenta el diseño e implementación de un **controlador proporcional (P)** aplicado a dos sistemas de primer orden:

- ⚡ **Circuito RC:** la variable de proceso es la tensión del capacitor y la acción de control se aplica mediante **PWM**.
- 🔥 **Horno eléctrico:** la variable de proceso es la temperatura medida con un **LM35**, y la acción de control mueve un **servomotor** que gira la perilla de un **dimmer**, regulando la potencia del foco. Una celda **Peltier** permanece encendida como carga de enfriamiento constante.

En ambos casos, la variable medida se compara con una **referencia** para calcular el error, y el controlador genera una señal proporcional a dicho error:

$$
u(t)=K_p e(t)
$$

A diferencia del controlador ON/OFF, el controlador proporcional genera **valores intermedios** de salida dentro de su intervalo de operación.

---

## 🎯 2. Objetivo

Implementar y analizar un controlador proporcional para regular la tensión de un circuito RC y la temperatura de un horno, evaluando el efecto de la ganancia $K_p$ sobre la respuesta y el **error en estado estable**.

El proyecto integra:

- 🔌 Un circuito RC y un horno como procesos físicos.
- 🌡️ Un sensor LM35 con filtro de promedio móvil (horno).
- 🤖 Arduino para el control y la adquisición de datos.
- 🎚️ Una referencia ajustable.
- 📐 El cálculo del error de control.
- ⚙️ Un controlador proporcional con saturación.
- 🔄 Un actuador PWM (RC) o servo + dimmer (horno).
- 💻 MATLAB para el análisis de datos.
- 🧩 Simulink para la implementación del lazo de control.

---

## 🧱 3. Arquitectura del sistema

1. **Referencia:** valor deseado de tensión (RC) o temperatura (horno).
2. **Punto de suma:** calcula el error entre la referencia y la medición.
3. **Controlador P + saturación:** multiplica el error por $K_p$ y limita la salida.
4. **Actuador y proceso:** PWM → RC, o servo → dimmer → foco → horno.
5. **Salida y retroalimentación:** se mide la variable y regresa al punto de suma.

### Diagrama funcional

```text
        Referencia r(t)
               |
               v
          +---------+
          |  SUMA   |<----------------------+
          |  +   -  |                       |
          +----+----+                       |
               | e(t)                       |
               v                            |
        +-------------+                     |
        | Controlador |                     |
        |  P + Sat.   |                     |
        | u(t)=Kp*e(t)|                     |
        +------+------+                     |
               | u(t)                       |
               v                            |
        +---------------+                   |
        |   Actuador    |                   |
        | PWM / Servo + |                   |
        |    dimmer     |                   |
        +------+--------+                   |
               |                            |
               v                            |
        +---------------+                   |
        |    Proceso    |                   |
        |  RC / Horno   |                   |
        | G(s)=K/(τs+1) |                   |
        +------+--------+                   |
               |                            |
               v                            |
     Salida y(t) (+ filtro) ----------------+
```

---

## 📐 4. Fundamento teórico

### 4.1. Modelo del proceso

Ambos procesos se aproximan con un modelo de primer orden:

$$
G(s)=\frac{K}{\tau s+1}
$$

| Parámetro | Circuito RC | Horno |
|---|---|---|
| Salida $y(t)$ | Tensión del capacitor [V] | Temperatura [°C] |
| Acción $u(t)$ | Voltaje PWM, 0 a 5 V | Potencia del foco, 0 a 100 % |
| $K$ | ≈ 1 | °C por cada % de potencia |
| $\tau$ | $\tau = RC$ ≈ 1 s | Constante de tiempo térmica (minutos) |

### 4.2. Señal de error

$$
e(t)=r(t)-y(t)
$$

- Si la salida es **menor** que la referencia, el error es positivo y la acción de control **aumenta**.
- Si la salida es **mayor** que la referencia, el error es negativo y la acción de control **disminuye** (hasta 0, por la saturación).

### 4.3. Ley de control con saturación

$$
u(t)=\min\left(u_{max},\max\left(0,K_p e(t)\right)\right)
$$

| Sistema | $u_{max}$ | Unidades de $K_p$ |
|---|---|---|
| Circuito RC | 5 V | V/V |
| Horno | 100 % | % por °C |

### 4.4. Efecto de la ganancia proporcional

| Ganancia | Comportamiento esperado |
|---|---|
| $K_p$ pequeño | Acción de control reducida, respuesta lenta y error grande. |
| $K_p$ moderado | Respuesta más rápida y menor error. |
| $K_p$ elevado | Mayor saturación, ruido amplificado y posible oscilación del actuador. |

---

## 📊 5. Función de transferencia en lazo cerrado

Con realimentación unitaria negativa:

$$
T(s)=\frac{K_pG(s)}{1+K_pG(s)}=\frac{K_pK}{\tau s+1+K_pK}
$$

Constante de tiempo en lazo cerrado:

$$
\tau_{CL}=\frac{\tau}{1+K_pK}
$$

Ganancia estática en lazo cerrado:

$$
K_{CL}=\frac{K_pK}{1+K_pK}
$$

Error en estado estable ante una referencia escalón de amplitud $r$:

$$
e_{ss}=\frac{r}{1+K_pK}
$$

> 💡 **El control P no elimina el error en estado estable.** Para mantener el foco encendido (y compensar a la Peltier), el controlador **necesita** que exista error. Por eso el horno se estabiliza ligeramente por debajo de la referencia.

En el horno, las expresiones se aplican sobre las **variaciones** respecto al punto de operación (temperatura ambiente y efecto constante de la Peltier). Las expresiones son válidas mientras la salida no esté saturada.

---

## 🌡️ 6. Rango de operación del horno

Con la Peltier encendida, el horno tiene un rango limitado de temperaturas alcanzables:

| Condición | Resultado |
|---|---|
| Dimmer al 0 % + Peltier ON | **Tmin**: la temperatura más baja alcanzable |
| Dimmer al 100 % + Peltier ON | **Tmax**: la temperatura más alta alcanzable |

La **referencia debe estar entre Tmin y Tmax**. Si está fuera de ese rango, el controlador se queda saturado en 0 % o 100 % y nunca la alcanza.

A partir de ambas mediciones se estima la ganancia del proceso:

$$
K\approx\frac{T_{max}-T_{min}}{100}\ \ [°C/\%]
$$

---

## 🔌 7. Implementación con Arduino

### 7.1. Conexiones

**Circuito RC**

| Elemento | Pin Arduino |
|---|---|
| Resistencia R (salida PWM) | `3` |
| Nodo R–C (tensión del capacitor) | `A0` |
| Capacitor C | `GND` |

**Horno**

| Elemento | Pin Arduino | Estado |
|---|---|---|
| LM35 (Vout) | `A0` | Medición |
| Servo del dimmer | `9` | Acción de control |
| Relé Peltier + ventiladores | `11` | Siempre ON (`0`) |
| Relé extractor | `12` | Siempre OFF (`1`) |
| Foco | Dimmer | Sin relé |

> 💡 El servo debe alimentarse con una **fuente de 5 V independiente**, con GND común al Arduino. El dimmer trabaja con **127 V AC**: el servo solo debe tocar la perilla mediante un acople aislante.

### 7.2. Conversión de la lectura analógica

$$
V_{in}=\frac{5N}{1023}
\qquad\qquad
T=\frac{500N}{1023}
$$

En el horno se aplica un **filtro de promedio móvil de 5 muestras** antes de calcular el error.

### 7.3. Conversión de la acción de control al actuador

**RC (PWM de 8 bits):**

$$
PWM=u\cdot\frac{255}{5}
$$

**Horno (servo):** se miden experimentalmente el ángulo donde el foco **empieza a encender** ($a_{min}$) y el ángulo donde queda **al máximo** ($a_{max}$):

$$
\theta=a_{min}+u\cdot\frac{a_{max}-a_{min}}{100}
$$

Valores medidos: $a_{min}=122^\circ$, $a_{max}=180^\circ$, de modo que:

$$
\theta=122+0.58\,u
$$

Gracias a la saturación de 0 a 100 %, el servo **nunca** recibe un ángulo fuera de 122° a 180°.

---

## 💻 8. Modelo en Simulink

| Bloque | Circuito RC | Horno |
|---|---|---|
| Arduino IO Setup | `a`, `COM4` | `a`, `COM4` |
| Real-Time Pacer | Speedup = 1 | Speedup = 1 |
| Constant (referencia) | `2` V | `35`–`40` °C |
| Sum | `+-` | `+-` |
| Gain ($K_p$) | `10` | `Kp` (10) |
| Saturation | `0` a `5` | `0` a `100` |
| Conversión al actuador | Gain `255/5` | Gain `(aMax-aMin)/100` + Bias `aMin` |
| Actuador | Analog Write pin `3` | **Servo Write** pin `9` |
| Lectura | Analog Read pin `0` | Analog Read pin `0` |
| Conversión | Gain `5/1023` | Gain `500/1023` |
| Filtro | — | 4 × Unit Delay (IC = `T0`) + Sum `+++++` + Gain `1/5` |
| Relés fijos | — | Constant `0` → Digital Write pin `11`; Constant `1` → Digital Write pin `12` |
| Scopes | Error, acción, referencia y salida | Error, acción, referencia y salida |
| Mux → To Workspace | `out.data` | `out.data` |

Registro en `out.data` (Mux, una columna por entrada):

| Columna | Señal |
|---|---|
| 1 | Referencia |
| 2 | Salida medida (V o °C) |

Configuración del modelo: Solver **Fixed-step** (0.5 s en el horno), Stop Time `inf`.

> ⚠️ En el horno se debe usar el bloque **Servo Write**, no **Analog Write**: el servo no responde a una señal PWM de 0 a 255.

---

## ⚙️ 9. Configuración (`config.m`)

**Circuito RC**

```matlab
%% Declarar PATH con funciones de Simulink
addpath('C:\Users\Gel98\OneDrive\Escritorio\MATLAP\ArduinoIO\simulink')

%% Declarar Arduino
delete(instrfind({'Port'},{'COM4'}))
a = myarduino('COM4');

%% Configuracion de puerto
pinMode(a,3,'output');      % Salida PWM hacia el circuito RC
```

**Horno**

```matlab
%% Declarar PATH con funciones de Simulink
addpath('C:\Users\Gel98\OneDrive\Escritorio\MATLAP\ArduinoIO\simulink')

%% Declarar Arduino
delete(instrfind({'Port'},{'COM4'}))
a = myarduino('COM4');

%% Configuracion de puertos (reles activos en LOW -> 0 = ON, 1 = OFF)
% LM35 en A0 | Foco directo al dimmer (sin rele)
for p = [11 12]             % 11 Peltier + ventiladores | 12 Extractor
    digitalWrite(a,p,1);
    pinMode(a,p,'output');
    digitalWrite(a,p,1);
end

%% Servo del dimmer (pin 9)
aMin = 122;                 % foco empieza a encender
aMax = 180;                 % foco al maximo
servoAttach(a,9);
servoWrite(a,9,aMin);       % arrancar con el foco al minimo

%% Estado fijo durante la prueba
digitalWrite(a,11,0);       % Peltier + ventiladores ON
digitalWrite(a,12,1);       % Extractor OFF

%% Controlador
Kp = 10;                    % % de potencia por °C de error

%% Temperatura inicial (Initial condition de los Unit Delay del filtro)
T0 = analogRead(a,0)*500/1023;
fprintf('Listo. Temperatura inicial: %.1f °C\n', T0);
```

**Callbacks del horno** (*Model Properties → Callbacks*):

`StartFcn`

```matlab
try, servoAttach(a,9); catch, end
pinMode(a,11,'output'); pinMode(a,12,'output');
digitalWrite(a,11,0); digitalWrite(a,12,1);
```

`StopFcn`

```matlab
try, servoAttach(a,9); catch, end
servoWrite(a,9,aMin); digitalWrite(a,11,1); digitalWrite(a,12,1);
```

> 💡 Los callbacks son necesarios porque el bloque **Setup** reinicia la comunicación al iniciar la simulación, y se pierden el `servoAttach` y el estado de los relés configurados en el `config.m`.

---

## 📊 10. Análisis de datos (`analisis.m`)

**Circuito RC**

```matlab
%% DATOS adquiridos (Mux -> To Workspace)
t     = out.data.Time;
datos = squeeze(out.data.Data);
if size(datos,1) ~= numel(t), datos = datos.'; end

ref    = datos(:,1);     % referencia (V)
salida = datos(:,2);     % tension del capacitor (V)

%% Parametros del controlador
Kp = 10;

%% Señales recalculadas
error  = ref - salida;
accion = min(max(Kp*error, 0), 5);   % accion de control (V)

%% Grafica 1: Referencia y salida
figure
plot(t,ref,'r',t,salida,'b')
grid("on")
title("Control P de un sistema RC")
xlabel("Tiempo (s)")
ylabel("Voltaje (V)")
legend("Referencia","Salida")

%% Grafica 2: Error
figure
plot(t,error,'m')
grid("on")
title("Error del sistema")
xlabel("Tiempo (s)")
ylabel("Error (V)")

%% Grafica 3: Accion de control
figure
plot(t,accion,'r')
grid("on")
title("Acción de control")
xlabel("Tiempo (s)")
ylabel("u (V)")

%% Resultados
n = max(1, round(numel(t)*0.1));
fprintf('\nError estado estable : %.3f V\n', mean(error(end-n+1:end)));
```

**Horno**

```matlab
%% DATOS adquiridos (Mux -> To Workspace)
t     = out.data.Time;
datos = squeeze(out.data.Data);
if size(datos,1) ~= numel(t), datos = datos.'; end

ref  = datos(:,1);      % referencia (°C)
temp = datos(:,2);      % temperatura (°C)

%% Parametros del controlador (los mismos del modelo)
Kp   = 10;
aMin = 122;
aMax = 180;

%% Señales recalculadas
error  = ref - temp;                         % error (°C)
accion = min(max(Kp*error, 0), 100);         % accion de control (%)
angulo = aMin + accion*(aMax - aMin)/100;    % angulo del servo (°)

%% Grafica 1: Referencia y temperatura
figure
plot(t,ref,'r',t,temp,'b')
grid("on")
title("Respuesta del horno con control P")
xlabel("Tiempo (s)")
ylabel("Temperatura (°C)")
legend("Referencia","Temperatura")

%% Grafica 2: Error
figure
plot(t,error,'m')
grid("on")
title("Error del sistema")
xlabel("Tiempo (s)")
ylabel("Error (°C)")

%% Grafica 3: Accion de control
figure
plot(t,accion,'r')
grid("on")
ylim([-5 105])
title("Acción de control")
xlabel("Tiempo (s)")
ylabel("Potencia del foco (%)")

%% Grafica 4: Angulo del servo
figure
plot(t,angulo,'k')
grid("on")
ylim([aMin-5 aMax+5])
title("Ángulo del servo (dimmer)")
xlabel("Tiempo (s)")
ylabel("Ángulo (°)")

%% Resultados en consola
n = max(1, round(numel(t)*0.1));             % ultimo 10% de los datos
fprintf('\nReferencia           : %.1f °C\n', ref(end));
fprintf('Temperatura final    : %.1f °C\n', mean(temp(end-n+1:end)));
fprintf('Error estado estable : %.2f °C\n', mean(error(end-n+1:end)));
fprintf('Temperatura maxima   : %.1f °C\n', max(temp));
```

---

## 🧪 11. Metodología experimental

### Etapa 1. Preparación

1. Montar el circuito (RC u horno) y verificar las conexiones.
2. Cargar el sketch `adiosrv` de ArduinoIO al Arduino.
3. En el horno, calibrar el servo: encontrar $a_{min}$ y $a_{max}$ moviendo el servo desde la consola con `servoWrite(a,9,angulo)`.
4. En el horno, medir **Tmin** y **Tmax** con la Peltier encendida (dimmer al 0 % y al 100 %).

### Etapa 2. Configuración

1. Ejecutar el `config.m` correspondiente.
2. Establecer la referencia (en el horno, entre Tmin y Tmax).
3. Configurar $K_p$ y la saturación.
4. En el horno, verificar los callbacks `StartFcn` y `StopFcn`.

### Etapa 3. Ejecución

1. Presionar **Run** en Simulink.
2. Observar el error, la acción de control y la salida en los Scopes.
3. Esperar a que la salida se estabilice y detener la simulación.

### Etapa 4. Análisis

1. Ejecutar el `analisis.m`.
2. Graficar la referencia, la salida, el error y la acción de control.
3. Determinar el error en estado estable.
4. Repetir con diferentes valores de $K_p$ y comparar.

---

## 📈 12. Experimentos propuestos

| Experimento | $K_p$ | Referencia RC | Referencia horno |
|---|---:|---:|---:|
| 1 | 1 | 2 V | 35 °C |
| 2 | 5 | 2 V | 35 °C |
| 3 | 10 | 2 V | 35 °C |
| 4 | 20 | 2 V | 35 °C |

Variables a registrar: tiempo, referencia, salida, error, acción de control y $K_p$.

---

## 📋 13. Indicadores de evaluación

| Indicador | Descripción |
|---|---|
| Tiempo de establecimiento | Tiempo para alcanzar y mantenerse cerca del valor final. |
| Error en estado estable | Diferencia final entre referencia y salida. |
| Sobreimpulso | Máximo excedente respecto a la referencia. |
| Saturación | Tiempo en que la acción de control está en 0 o en su máximo. |
| Ruido en la acción | Variación del actuador causada por el ruido de la medición. |
| Rango de operación | Tmin y Tmax del horno con la Peltier encendida. |

---

## 📚 14. Conclusión

El controlador proporcional ajusta la acción de control según la magnitud del error, logrando que la salida se acerque a la referencia con mayor rapidez que en lazo abierto.

En ambos sistemas se observa la característica principal del control P: **un error en estado estable que disminuye al aumentar $K_p$, pero no desaparece**. En el horno, además, un $K_p$ elevado amplifica el ruido del sensor y provoca movimientos innecesarios del servo, lo que limita la ganancia utilizable. Estas limitaciones motivan la incorporación de las acciones **integral** y **derivativa** en un controlador **PID**.

---

## 📁 15. Estructura del proyecto

```text
Control_Proporcional/
│
├── README.md
│
├── RC/
│   ├── config.m
│   ├── analisis.m
│   └── modelo_control_p_rc.slx
│
├── Horno/
│   ├── config.m
│   ├── analisis.m
│   ├── prueba_horno.ino
│   └── modelo_control_p_horno.slx
│
└── img/
    ├── esquematico.png
    ├── diagrama_simulink.png
    └── respuesta.png
```

---

### 👨‍💻 Tecnologías utilizadas

- Arduino
- MATLAB
- Simulink
- Circuito RC
- Sensor LM35
- Servomotor y dimmer
- Celda Peltier
- Control proporcional (P)
- Modulación por ancho de pulso (PWM)

**Proyecto educativo de control automático y sistemas dinámicos.**
