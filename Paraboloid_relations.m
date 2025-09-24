% MATLAB SCRIPT TO ANALYZE A TRUNCATED PARABOLOID CONCENTRATOR
% This script is based on the relationship derived by the user:
% |x| = 2a / tan(theta/2)

% Clear workspace and command window
clear;
clc;
close all;

% =========================================================================
%% Step 1: User Input for Angle
% =========================================================================
fprintf('--- Truncated Paraboloid Design ---\n');
theta = input('Enter your desired acceptance angle (theta) in degrees: ');

if isempty(theta) || ~isnumeric(theta) || theta <= 0 || theta >= 180
    error('Invalid input. Please enter a number between 0 and 180.');
end

% =========================================================================
%% Step 2: Calculate and Display the Relationship
% =========================================================================
% Calculate the ratio of the bottom radius 'x' to the focal length 'a'
theta_rad_half = deg2rad(theta / 2);
x_over_a = 2 / tan(theta_rad_half);

% Calculate the ratio of the rim height 'y_rim' to the focal length 'a'
y_rim_over_a = 1 / (tan(theta_rad_half)^2);

fprintf('\n--- Geometric Relationship ---\n');
fprintf('For an acceptance angle of %.1f degrees:\n', theta);
fprintf('The bottom opening radius (x) must be %.2f times the focal length (a).\n', x_over_a);
fprintf('The height of the bottom rim (y_rim) will be %.2f times the focal length (a).\n', y_rim_over_a);

% =========================================================================
%% Step 3: User Input for Focal Length and Final Calculations
% =========================================================================
fprintf('\n--- Finalize Dimensions ---\n');
a = input('Enter a value for the focal length (a) in mm: ');

if isempty(a) || ~isnumeric(a) || a <= 0
    error('Invalid input. Please enter a positive number for the focal length.');
end

% Calculate the final dimensions
x_rim = a * x_over_a;
y_rim = a * y_rim_over_a;
d_rim = 2 * x_rim;

fprintf('\n--- Your Final Paraboloid Dimensions ---\n');
fprintf('Focal Length (a):      %.2f mm\n', a);
fprintf('Bottom Opening Radius (x): %.2f mm\n', x_rim);
fprintf('Bottom Opening Diameter: %.2f mm\n', d_rim);
fprintf('Height of Bottom Rim:    %.2f mm\n', y_rim);

% =========================================================================
%% Step 4: Visualization
% =========================================================================
% To show the shape, we define an arbitrary upper rim for the dish
x_upper = x_rim * 1.5; % Make the top 1.5x wider than the bottom opening
y_upper = x_upper^2 / (4*a);

% Generate points for the full parabolic curve
x_coords = linspace(-x_upper, x_upper, 500);
y_coords = x_coords.^2 / (4*a);

% Filter points to show only the truncated part (above the bottom rim)
indices_to_keep = y_coords >= y_rim;
x_plot = x_coords(indices_to_keep);
y_plot = y_coords(indices_to_keep);

% Create the plot
figure;
hold on;
plot(x_plot, y_plot, 'b', 'LineWidth', 2); % Plot the dish walls
plot(0, a, 'r*', 'MarkerSize', 10); % Mark the focal point

% Add annotations
line([-x_rim, x_rim], [y_rim, y_rim], 'Color', 'g', 'LineStyle', '--');
text(0, y_rim, sprintf(' Bottom Opening (%.2f mm)', d_rim), 'VerticalAlignment', 'top');
text(0, a, '  Focal Point', 'Color', 'r');

% Formatting
hold off;
grid on;
axis equal;
title(sprintf('Truncated Paraboloid (\\theta = %.1f°, a = %.1f mm)', theta, a));
xlabel('Radius (mm)');
ylabel('Height (mm)');
legend('Paraboloid Wall', 'Focal Point');