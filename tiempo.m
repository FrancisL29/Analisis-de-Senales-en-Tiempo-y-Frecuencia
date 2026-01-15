%% GRÁFICA EXCLUSIVA DE h(t) - FILTRO PASA-ALTAS
clear; clc; close all;

% --- 1. Parámetros del Filtro ---
fc = 250;            % Frecuencia de corte (Hz)
a = 2 * pi * fc;     % Frecuencia angular (rad/s) ~ 1570.8 rad/s

% --- 2. Configuración del Tiempo (ZOOM) ---
% La "constante de tiempo" tau = 1/a es aprox 0.6 milisegundos.
% Para ver la curva bien, graficamos 5 veces esa constante (aprox 3ms).
t_final = 0.004;     % 4 milisegundos
fs_sim = 100000;     % Alta resolución para que la curva se vea suave
t = 0 : 1/fs_sim : t_final;

% --- 3. Definición de la Ecuación h(t) ---
% La inversa teórica de H(s) = s/(s+a) es: h(t) = delta(t) - a*e^(-at)

% Parte A: El impulso Delta (Solo existe en t=0)
% Lo representamos gráficamente con un valor simbólico
t_impulso = 0;
val_impulso = 1; % Representación simbólica de la Delta

% Parte B: La exponencial negativa (u(t))
% h_cont = -a * e^(-at)
h_continuo = -a * exp(-a * t);

%% 4. Generación de la Gráfica
figure('Name', 'Respuesta al Impulso h(t)', 'Color', 'w', 'Position', [300, 300, 700, 500]);

hold on;
% Línea de referencia cero
yline(0, 'k-', 'LineWidth', 1);

% a) Graficamos la parte Exponencial (La curva roja abajo)
plot(t, h_continuo, 'r', 'LineWidth', 2.5, 'DisplayName', 'Parte: -a e^{-at}');

% b) Graficamos el Impulso (La flecha azul arriba)
% Usamos 'stem' para que parezca una delta de Dirac
stem(t_impulso, max(abs(h_continuo))/2, 'b', 'LineWidth', 2.5, ...
    'MarkerFaceColor', 'b', 'DisplayName', 'Parte: \delta(t)');
% Nota: Puse la altura del stem relativa a la curva para que se vea estético,
% ya que matemáticamente la delta es altura infinita.

hold off;

% --- 5. Decoración ---
grid on;
title(['Respuesta al Impulso h(t) para f_c = ' num2str(fc) ' Hz']);
subtitle('h(t) = \delta(t) - a e^{-at} u(t)');
xlabel('Tiempo (segundos)');
ylabel('Amplitud');


% Ajustes de Ejes
xlim([0 t_final]);
% Expandimos un poco el eje Y para ver bien el impulso y la curva
ylim([min(h_continuo)*1.1, max(abs(h_continuo))*0.6]); 

