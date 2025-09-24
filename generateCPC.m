function [cpc_params, fig_handle] = generateCPC(d_exit, theta_max)
    % A function to design, calculate, and visualize a 3D Compound Parabolic
    % Concentrator (CPC).
    % FINAL CORRECTED VERSION - 22 Sept 2025

    %% Step 1: Input Validation
    if nargin ~= 2
        error('This function requires two inputs: d_exit and theta_max.');
    end
    if d_exit <= 0 || theta_max <= 0 || theta_max >= 90
        error('Inputs must be within the valid range: d_exit > 0 and 0 < theta_max < 90.');
    end

    %% Step 2: Core Calculations
    r_exit = d_exit / 2;
    theta_rad = deg2rad(theta_max);

    r_entrance = r_exit / sin(theta_rad);
    d_entrance = 2 * r_entrance;
    concentration = 1 / (sin(theta_rad)^2);
    H = (r_entrance + r_exit) * cot(theta_rad);

    cpc_params.d_exit = d_exit;
    cpc_params.theta_max = theta_max;
    cpc_params.d_entrance = d_entrance;
    cpc_params.H = H;
    cpc_params.concentration = concentration;

    %% Step 3: Generate the 2D Profile Points (Corrected Geometric Method)
    % This version builds a standard VERTICAL parabola and then rotates and 
    % shifts it into the final position. This is the correct geometric approach.
    
    f = r_exit * (1 + sin(theta_rad)); % Focal length of the generating parabola
    
    % 1. Create a standard parabola opening upwards (x^2 = 4fy)
    % We generate it with a very large height to ensure we can carve out the CPC.
    x_p = linspace(-3*r_entrance, 3*r_entrance, 2000); % Parametric x-points
    y_p = x_p.^2 / (4*f);                             % Parametric y-points
    
    % 2. Rotate the parabola by the acceptance angle
    x_rot = x_p*cos(theta_rad) - y_p*sin(theta_rad);
    y_rot = x_p*sin(theta_rad) + y_p*cos(theta_rad);
    
    % 3. Translate the rotated parabola so its focus is at (-r_exit, 0)
    % The focus of the original vertical parabola is at (0, f).
    % After rotation, the focus is at (-f*sin(theta), f*cos(theta)).
    % We calculate the shift needed to move this point to (-r_exit, 0).
    shift_x = -r_exit - (-f*sin(theta_rad));
    shift_y = 0 - (f*cos(theta_rad));
    
    x_R = x_rot + shift_x;
    y_R = y_rot + shift_y;
    
    % 4. Filter the points to keep only the valid CPC wall
    indices_to_keep = (y_R <= H + 1e-6) & (y_R >= -1e-6) & (x_R >= 0);
    x_R = x_R(indices_to_keep);
    y_R = y_R(indices_to_keep);
    
    % Sort the points to ensure correct plotting order
    [y_R, sort_idx] = sort(y_R);
    x_R = x_R(sort_idx);

    % The left wall is a mirror image
    x_L = -x_R;
    y_L = y_R;
    
    %% Step 4: Create the 2D Visualization
    fig_handle = figure('Name', 'CPC Design Visualization', 'Position', [100, 100, 1200, 600]);
    
    subplot(1, 2, 1);
    hold on;
    plot(x_R, y_R, 'Color', '#4DBEEE', 'LineWidth', 2.5); % Right wall
    plot(x_L, y_L, 'Color', '#4DBEEE', 'LineWidth', 2.5); % Left wall
    
    line([-r_entrance, r_entrance], [H, H], 'Color', 'r', 'LineStyle', '--');
    line([-r_exit, r_exit], [0, 0], 'Color', 'g', 'LineStyle', '--');
    
    ray_x_start = -r_entrance;
    ray_y_start = H + H*0.1;
    ray_x_end = -r_exit;
    ray_y_end = 0;
    plot([ray_x_start, ray_x_end], [ray_y_start, ray_y_end], 'Color', '#FFA500', 'LineWidth', 1.5);
    text(ray_x_start, ray_y_start + H*0.02, '\theta_{max}', 'Color', '#FFA500', 'FontSize', 12);
    
    text(0, H, sprintf(' Entrance = %.2f mm', d_entrance), 'VerticalAlignment', 'bottom');
    text(0, 0, sprintf(' Exit = %.2f mm', d_exit), 'VerticalAlignment', 'top');
    line([r_entrance, r_entrance], [0, H], 'Color', 'k', 'LineStyle', ':');
    text(r_entrance, H/2, sprintf(' H = %.2f mm', H), 'HorizontalAlignment', 'left');

    hold off;
    axis equal;
    grid on;
    title('2D CPC Cross-Section (Corrected)');
    xlabel('Radius (mm)');
    ylabel('Height (mm)');
    
    %% Step 5: Create the 3D Visualization
    subplot(1, 2, 2);
    theta_3d = linspace(0, 2*pi, 50);
    
    if isempty(x_R) || isempty(y_R)
        disp('No points to plot for 3D model.');
        return;
    end

    X_3d = x_R' * cos(theta_3d);
    Z_3d = x_R' * sin(theta_3d);
    Y_3d = repmat(y_R', 1, 50);
    
    surf(X_3d, Y_3d, Z_3d, 'EdgeColor', 'none', 'FaceAlpha', 0.9, 'FaceColor', 'interp');
    
    colormap('winter');
    light('Position', [1 1 1], 'Style', 'infinite');
    lighting gouraud;
    material shiny;
    axis equal;
    grid on;
    title('3D CPC Model (Corrected)');
    xlabel('X (mm)');
    ylabel('Y (Height, mm)');
    zlabel('Z (mm)');
    view(30, 20);
end