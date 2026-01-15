%% Parámetros
a = 1;                % Constante del filtro
omega = linspace(-10, 10, 1000);  % Vector de frecuencias rad/s

%% Respuesta en frecuencia
H = 1 ./ (a + 1j*omega);

%% Magnitud y fase
magH = abs(H);
phaseH = angle(H);    % en radianes

%% Graficar
figure;

subplot(2,1,1)
plot(omega, magH, 'LineWidth', 2);
grid on;
xlabel('\omega [rad/s]');
ylabel('|H(j\omega)|');
title('Magnitud del filtro pasa-bajas');

subplot(2,1,2)
plot(omega, phaseH, 'LineWidth', 2);
grid on;
xlabel('\omega [rad/s]');
ylabel('\angle H(j\omega) [rad]');
title('Fase del filtro pasa-bajas');
