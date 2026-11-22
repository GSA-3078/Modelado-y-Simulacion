%% Limites usados en el modelo
HL = 40;    % limite superior (°C)
LL = 31;    % limite inferior (°C)

%% DATOS adquiridos de la entrada del proceso (foco: 1 = ON)
t = out.data.signal1.Time;
entrada = squeeze(out.data.signal1.Data);

%% DATOS adquiridos de la salida del proceso (temperatura filtrada)
salida = squeeze(out.data.signal2.Data);

%% Entrada escalada: 0 -> LL , 1 -> HL (solo para verla junto a la temperatura)
entrada_esc = LL + entrada*(HL - LL);

%% Graficacion del proceso
figure
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

%% Resultados
fprintf('\nTemperatura maxima : %.1f °C\n', max(salida));
fprintf('Temperatura minima : %.1f °C\n', min(salida(find(entrada==0,1):end)));
