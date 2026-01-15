%% 1. CONFIGURACIÓN Y CARGA
clear; clc; close all;

archivo = 'Te quiero - Hombres G.wav'; % <--- TU ARCHIVO
[x_raw, fs] = audioread(archivo);

% Convertir a mono
if size(x_raw, 2) > 1
    x_raw = mean(x_raw, 2);
end

% Recortar a 30 segundos
t_duracion = 30; 
num_muestras = t_duracion * fs;
if length(x_raw) > num_muestras
    x = x_raw(1:num_muestras);
else
    x = x_raw;
end

% --- NORMALIZACIÓN DE ENTRADA ---
x = x / max(abs(x));
audiowrite('audio_entrada_norm.wav', x, fs);
t = (0:length(x)-1)/fs;

%% 2. TRANSFORMACIÓN AL DOMINIO DE LA FRECUENCIA
N = length(x);
f = (-N/2 : N/2 - 1) * (fs / N); 
w = 2 * pi * f;

% --- CORRECCIÓN DE ESCALA ---
% Dividimos por N para normalizar la magnitud visualmente
X_jw = fftshift(fft(x)) / N;

%% 3. CREACIÓN DEL FILTRO PASA-ALTAS
% Magnitud deseada: |H| = w / sqrt(a^2 + w^2)
% Función de Transferencia Compleja: H(jw) = jw / (a + jw)

fc = 120;            % Frecuencia de corte en Hz (Ajustado a tu reporte)
a = 2 * pi * fc;     % Convertir a rad/s

% --- FÓRMULA PASA-ALTAS ---
% Numerador: j*w  (Derivador)
% Denominador: a + j*w (Polo)
H_jw = (1j .* w) ./ (a + 1j .* w); 

% Verificación rápida:
% En DC (w=0) el numerador es 0, así que la ganancia debe ser 0.
ganancia_DC = abs(H_jw(floor(N/2)+1)); 
fprintf('La ganancia en DC es: %.2f (Debería ser 0.0 para Pasa-Altas)\n', ganancia_DC);

%% 4. PROCESAMIENTO: Y(jw) = X(jw) * H(jw)
Y_jw = X_jw .* H_jw.';

%% 5. RECUPERACIÓN Y NORMALIZACIÓN
y_raw = real(ifft(ifftshift(Y_jw))); 
% Nota: Al haber dividido X por N, y_raw saldrá muy pequeño. 
% Pero la normalización siguiente lo arregla todo.

% Normalización de Salida
if max(abs(y_raw)) > 0
    y = y_raw / max(abs(y_raw));
else
    y = y_raw;
end

audiowrite('audio_salida_pasa_altas.wav', y, fs);

%% 6. GENERACIÓN DE GRÁFICAS
figure('Name', 'Análisis Filtro Pasa-Altas', 'Color', 'w', 'Position', [100, 50, 800, 1000]);

f_zoom = 1200; % Zoom para ver la zona de corte

% 1. Señal en el Tiempo x(t)
subplot(5,1,1);
plot(t, x, 'b'); 
title('1. Entrada en el Tiempo x(t)');
xlabel('Tiempo (s)'); ylabel('Amplitud'); axis tight; grid on;

% Calculamos el máximo de la entrada para usarlo de referencia
max_val = max(abs(X_jw)); 

% 2. Espectro de Entrada X(jw)
subplot(5,1,2);
plot(f, abs(X_jw), 'b');
title('2. Espectro de Entrada |X(j\omega)|');
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
xlim([-f_zoom f_zoom]); 
ylim([0 max_val]); % Escala fija
grid on;

% 3. Respuesta del Filtro H(jw)
subplot(5,1,3);
plot(f, abs(H_jw), 'r', 'LineWidth', 1.5);
title(['3. Filtro Pasa-Altas |H(j\omega)| (Corte = ' num2str(fc) ' Hz)']);
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
xlim([-f_zoom f_zoom]); grid on;
% Marcas verticales
xline(fc, '--k'); xline(-fc, '--k');

% 4. Espectro de Salida Y(jw)
subplot(5,1,4);
plot(f, abs(Y_jw), 'g');
title('4. Espectro de Salida |Y(j\omega)| ');
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
xlim([-f_zoom f_zoom]); 
ylim([0 max_val]); % MISMA ESCALA QUE LA ENTRADA
grid on;

% 5. Salida en el Tiempo y(t)
subplot(5,1,5);
plot(t, y, 'g');
title('5. Salida en el Tiempo y(t) ');
xlabel('Tiempo (s)'); ylabel('Amplitud'); axis tight; grid on;