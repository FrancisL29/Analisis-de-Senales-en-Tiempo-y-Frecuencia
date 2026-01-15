%% Configuración
clear; clc; close all;

a = 1; % Normalizado para ver la forma estándar

%% 1. Dominio del Tiempo: h(t)
% Vector de tiempo (incluimos un poco de negativo para ver que es causal)
t_cont = 0 : 0.01 : 5;       % Para la exponencial
t_neg = -1 : 0.01 : 0;       % Para mostrar el cero antes
h_exp = -exp(-a * t_cont);   % La parte exponencial negativa

%% 2. Dominio de la Frecuencia: |H(jw)| (Bilateral)
% Vector de frecuencia simétrico (Negativos y Positivos)
w = -10 : 0.05 : 10; 

% Cálculo de Magnitud
H_mag = abs(w) ./ sqrt(a^2 + w.^2);

%% 3. Gráficas Limpias
figure('Name', 'Formas de Onda: Pasa-Altas', 'Color', 'w');

% --- Gráfica Superior: Tiempo h(t) ---
subplot(2, 1, 1);
hold on;
% Línea base en cero
yline(0, 'Color', [0.7 0.7 0.7]); 
% Parte cero anterior
plot(t_neg, zeros(size(t_neg)), 'k', 'LineWidth', 1.5); 
% Parte exponencial (curva roja hacia abajo)
plot(t_cont, h_exp, 'r', 'LineWidth', 2); 
% Impulso (Delta) en el origen
stem(0, 1, 'b', 'LineWidth', 2, 'MarkerFaceColor', 'b'); 
hold off;

title(['Domino del Tiempo: h(t) = \delta(t) - e^{-at}u(t)  (con a=' num2str(a) ')']);
xlabel('Tiempo (s)');
grid on; axis tight; ylim([-1.2 1.2]);


% --- Gráfica Inferior: Frecuencia |H(jw)| ---
subplot(2, 1, 2);
plot(w, H_mag, 'k', 'LineWidth', 2);

title('Dominio de la Frecuencia: Magnitud |H(j\omega)|)');
xlabel('Frecuencia Angular \omega (rad/s)');
ylabel('Magnitud');
grid on; axis tight;
% Línea vertical central para referencia
