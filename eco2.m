%% 1. CONFIGURACIÓN Y CARGA
clear; clc; close all;

archivo = 'Te quiero - Hombres G.wav'; % <--- TU ARCHIVO
[x_raw, fs] = audioread(archivo);

% Convertir a mono
if size(x_raw, 2) > 1
    x_raw = mean(x_raw, 2);
end

% Recortar a 30 segundos (Necesario para ver los ecos de 10s y 20s)
t_duracion = 30; 
num_muestras = t_duracion * fs;
if length(x_raw) > num_muestras
    x = x_raw(1:num_muestras);
else
    x = x_raw;
    disp('Advertencia: El audio es menor a 30s, los ecos pueden cortarse.');
end

% --- NORMALIZACIÓN DE ENTRADA ---
x = x / max(abs(x));
t = (0:length(x)-1)/fs;

%% 2. TRANSFORMACIÓN AL DOMINIO DE LA FRECUENCIA
N = length(x);
f = (-N/2 : N/2 - 1) * (fs / N); 
w = 2 * pi * f;

% --- CORRECCIÓN DE ESCALA ---
% Dividimos por N para normalizar la magnitud visualmente
X_jw = fftshift(fft(x)) / N;

%% 3. CREACIÓN DEL SISTEMA DE ECOS H(jw)
% Fórmula: H(jw) = 1 + alpha1*e^(-jwT1) + alpha2*e^(-jwT2)

% Parámetros solicitados
alpha1 = 0.8;  T1 = 10; % Eco fuerte a los 10 segundos
alpha2 = 0.4;  T2 = 20; % Eco medio a los 20 segundos

% Definición de la Función de Transferencia (Filtro Peine)
% Nota: Se suman exponenciales complejas
H_jw = 1 + alpha1 * exp(-1j * w * T1) + alpha2 * exp(-1j * w * T2);

% Verificación: Ganancia Máxima teórica = 1 + 0.8 + 0.4 = 2.2
% Verificación: Ganancia Mínima teórica = 1 - 0.8 - 0.4 = -0.2 (en magnitud abs sería 0.2)

%% 4. PROCESAMIENTO: Y(jw) = X(jw) * H(jw)
Y_jw = X_jw .* H_jw.';

%% 5. RECUPERACIÓN Y NORMALIZACIÓN
y_raw = real(ifft(ifftshift(Y_jw)));

% Normalización de Salida
% Como los ecos se suman, la señal puede crecer hasta 2.2 veces. Normalizamos.
if max(abs(y_raw)) > 0
    y = y_raw / max(abs(y_raw));
else
    y = y_raw;
end

audiowrite('audio_con_ecos_largos.wav', y, fs);
disp('Audio con ecos guardado.');

%% 6. GENERACIÓN DE GRÁFICAS
figure('Name', 'Análisis de Sistema de Ecos', 'Color', 'w', 'Position', [100, 50, 800, 1000]);

% Zoom específico: Como T es muy grande, la oscilación en frecuencia es muy rápida.
% Si hacemos mucho zoom, veremos el "peine".
f_zoom = 600; 

% 1. Señal en el Tiempo x(t)
subplot(5,1,1);
plot(t, x, 'b'); 
title('1. Entrada en el Tiempo x(t)');
xlabel('Tiempo (s)'); ylabel('Amplitud'); axis tight; grid on;

% Referencia de magnitud máxima
max_val = max(abs(X_jw)); 

% 2. Espectro de Entrada X(jw)
subplot(5,1,2);
plot(f, abs(X_jw), 'b');
title('2. Espectro de Entrada |X(j\omega)|');
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
xlim([-f_zoom f_zoom]); 
ylim([0 max_val]); 
grid on;

% 3. Respuesta del Sistema H(jw)
subplot(5,1,3);
plot(f, abs(H_jw), 'r'); % Quitamos 'LineWidth' grueso para ver detalles finos
title(['3. Respuesta del Sistema de Ecos |H(j\omega)| (Filtro Peine)']);
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
xlim([-5 5]); % ZOOM EXTREMO: Solo vemos de -5 a 5 Hz para apreciar la oscilación
grid on;
% Nota: Con T=10s, el ciclo se repite cada 0.1 Hz. Es muy rápido.

% 4. Espectro de Salida Y(jw)
subplot(5,1,4);
plot(f, abs(Y_jw), 'g');
title('4. Espectro de Salida |Y(j\omega)| (Modulado por el Peine)');
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
xlim([-f_zoom f_zoom]); 
% ylim([0 max_val * 2.2]); % El techo sube porque ganamos energía
grid on;

% 5. Salida en el Tiempo y(t)
subplot(5,1,5);
plot(t, y, 'g');
title('5. Salida con Ecos y(t)');
xlabel('Tiempo (s)'); ylabel('Amplitud'); axis tight; grid on;

% Marcas visuales en el tiempo donde ocurren los ecos
xline(10, '--k', 'Eco 1');
xline(20, '--k', 'Eco 2');