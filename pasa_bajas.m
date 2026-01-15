%% 1. CONFIGURACIÓN Y CARGA
clear; clc; close all;

archivo = 'Te quiero - Hombres G.wav'; % <--- Pon el nombre de tu archivo aquí

[x_raw, fs] = audioread(archivo);

% Convertir a mono si es estéreo
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

% --- NORMALIZACIÓN DE ENTRADA (Solicitado) ---
% Esto asegura que la amplitud máxima sea 1 antes de procesar
x = x / max(abs(x));

% Guardar audio de entrada recortado y normalizado
audiowrite('audio_entrada_norm.wav', x, fs);

% Vector de tiempo para gráficas
t = (0:length(x)-1)/fs;

%% 2. TRANSFORMACIÓN AL DOMINIO DE LA FRECUENCIA
N = length(x);
f = (-N/2 : N/2 - 1) * (fs / N); 
w = 2 * pi * f;

% --- CORRECCIÓN DE ESCALA ---
% Dividimos por N para normalizar la magnitud
X_jw = fftshift(fft(x)) / N;

%% 3. CREACIÓN DEL FILTRO H(jw) NORMALIZADO
% Filtro Pasa-Bajas: H(jw) = a / (a + jw)
fc = 120;            % Frecuencia de corte en Hz
a = 2 * pi * fc;     % Convertir a rad/s

% --- CORRECCIÓN CLAVE ---
% Usamos 'a' en el numerador para que la ganancia máxima sea 1.
% Como usamos números complejos (1j), la FASE se calcula automáticamente.
H_jw = a ./ (a + 1j .* w); 

% Verificación rápida en consola:
ganancia_DC = abs(H_jw(floor(N/2)+1)); % En el centro (f=0)
fprintf('La ganancia en DC es ahora: %.2f (Debería ser 1.0)\n', ganancia_DC);

%% 4. PROCESAMIENTO: Y(jw) = X(jw) * H(jw)
% MATLAB opera con complejos: (Mag_X * Mag_H) y (Fase_X + Fase_H)
Y_jw = X_jw .* H_jw.';


%% 5. RECUPERACIÓN AL TIEMPO Y NORMALIZACIÓN DE SALIDA
y_raw = real(ifft(ifftshift(Y_jw)));

% --- NORMALIZACIÓN DE SALIDA (Crucial para escuchar) ---
% Como el filtro atenúa mucho la energía, la señal resultante es muy bajita.
% La amplificamos para que el pico máximo vuelva a ser 1.
factor_ganancia = 1 / max(abs(y_raw));
y = y_raw * factor_ganancia;

fprintf('La señal de salida se amplificó %.2f veces para normalizarla.\n', factor_ganancia);

% Guardar audio de salida
audiowrite('audio_salida_filtrado_norm.wav', y, fs);

%% 6. GENERACIÓN DE LAS 5 GRÁFICAS SOLICITADAS
figure('Name', 'Análisis Completo de Señales y Sistemas', 'Color', 'w', 'Position', [100, 50, 800, 1000]);

% Rango de visualización de frecuencia (Zoom para ver detalles, ej: -500 a 500 Hz)
% Si quieres ver todo, cambia xlim a [-fs/2 fs/2]
f_zoom = 1200; 

% 1. Señal en el Tiempo x(t)
subplot(5,1,1);
plot(t, x, 'b'); 
title('1. Entrada en el Tiempo x(t)');
xlabel('Tiempo (s)'); ylabel('Amplitud'); axis tight; grid on;

max_val = max(abs(X_jw)); % Buscamos el pico más alto de la entrada

% 2. Espectro de Entrada X(jw)
subplot(5,1,2);
plot(f, abs(X_jw), 'b');
title('2. Espectro de Entrada |X(j\omega)|');
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
xlim([-f_zoom f_zoom]); 
ylim([0 max_val]); % Fijamos el techo
grid on;

% 3. Respuesta del Filtro H(jw)
subplot(5,1,3);
plot(f, abs(H_jw), 'r', 'LineWidth', 1.5);
title(['3. Filtro |H(j\omega)|  (Corte = ' num2str(fc) ' Hz)']);
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
xlim([-f_zoom f_zoom]); grid on;
% Marcas verticales en la frecuencia de corte
xline(fc, '--k'); xline(-fc, '--k');

% 4. Espectro de Salida Y(jw)
subplot(5,1,4);
plot(f, abs(Y_jw), 'g');
title('4. Espectro de Salida |Y(j\omega)| ');
xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
xlim([-f_zoom f_zoom]); 
ylim([0 max_val]); % <--- IMPORTANTE: Usamos el MISMO techo que en X
grid on;

% 5. Salida en el Tiempo y(t)
subplot(5,1,5);
plot(t, y, 'g');
title('5. Salida en el Tiempo y(t)');
xlabel('Tiempo (s)'); ylabel('Amplitud'); axis tight; grid on;