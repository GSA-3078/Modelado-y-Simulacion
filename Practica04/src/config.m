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

%% Servo del dimmer (pin 9)
aMin = 122;                 % foco empieza a encender
aMax = 180;                 % foco al maximo
servoAttach(a,9);
servoWrite(a,9,aMin);       % arrancar con el foco al minimo

%% Estado fijo de los reles durante la prueba
digitalWrite(a,10,0);       % Foco ON (lo regula el dimmer)
digitalWrite(a,11,0);       % Peltier + ventiladores ON
digitalWrite(a,12,1);       % Extractor OFF

%% Temperatura inicial (para los Unit Delay del filtro)
T0 = analogRead(a,0)*500/1023;
fprintf('Listo. Temperatura inicial: %.1f °C\n', T0);
