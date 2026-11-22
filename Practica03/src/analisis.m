%% DATOS adquiridos (Mux -> To Workspace)
t     = out.data.Time;
datos = squeeze(out.data.Data);
if size(datos,1) ~= numel(t), datos = datos.'; end

ref   = datos(:,1);     % referencia (°C)
temp  = datos(:,2);     % temperatura (°C)

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
