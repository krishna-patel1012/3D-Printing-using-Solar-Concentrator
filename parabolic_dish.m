% Step 1: Clear the workspace and command window for a fresh start.
clear;
clc;

% Step 2: Define the target value from the first equation.
target_val = 0.4775 / 3;

% Step 3: Define a set of focal lengths (f) to plot.
f_values = [0.01, 0.02, 0.03, 0.04, 0.05, 0.1, 0.5, 1, 2];

% Step 4: Set up the figure and hold on to plot multiple lines.
figure;
hold on;
grid on;
box on;

% Initialize a cell array for the legend entries
legend_entries = cell(length(f_values), 1);

% Step 5: Loop through each focal length and solve for r and h.
for i = 1:length(f_values)
    f = f_values(i);
    
    % Define the function to solve. This is the first equation with h substituted.
    % We will solve for the root of this function to find r.
    fcn_to_solve = @(r) (r / (r^2/(4*f))^2) * ((r^2 + 4*(r^2/(4*f))^2)^1.5 - r^3) - target_val;
    
    % Use fzero to find the root (the value of r) for a given f.
    % We use a starting guess of 0.5.
    r_sol = fzero(fcn_to_solve, 0.5);
    
    % Calculate the corresponding h value.
    h_sol = r_sol^2 / (4 * f);
    
    % Plot the single solution point for this focal length.
    % We are plotting a single (r,h) pair for each f value.
    plot(r_sol, h_sol, 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0, 0.4470, 0.7410]);
    
    % Create a legend entry for this focal length
    legend_entries{i} = ['f = ' num2str(f)];
    
    % Optional: display the values in the command window
    fprintf('For f = %.1f, r = %.6f, h = %.6f\n', f, r_sol, h_sol);
end

% Step 6: Add labels, title, and legend to the graph.
xlabel('Radius (r)');
ylabel('Depth (h)');
title('Relationship between r, h, and f for the Solar Concentrator');
legend(legend_entries, 'Location', 'best');
hold off;