%% Declarar PATH con funciones de Simulink
addpath('C:\Users\Gel98\OneDrive\Escritorio\MATLAP\ArduinoIO\simulink')

%% Declarar Arduino
delete(instrfind({'Port'},{'COM4'}))
a = myarduino('COM4');

%% Configuracion de puertos (reles activos en LOW -> 0 = ON, 1 = OFF)
% LM35 en A0 (entrada analogica, no necesita pinMode)
% Primero HIGH y luego output, para que no hagan click al configurar
for p = [10 11 12]          % 10 Foco | 11 Peltier + ventiladores | 12 Extractor
    digitalWrite(a,p,1);
    pinMode(a,p,'output');
    digitalWrite(a,p,1);
end

%% Temperatura inicial (Initial condition de los 4 Unit Delay del filtro)
T0 = analogRead(a,0)*500/1023;
fprintf('Listo. Temperatura inicial: %.1f °C\n', T0);
