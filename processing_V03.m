%% download original data: maybe take alot of time and and depends on RAM of your computer
all_data = load('SL2013sv_25k-0.5d.mod'); 

%% select the data where our study area (20 - 45°) northing and easting
type_data = 'gridded'; % scattered; % 
zmin = 25; zmax = 400;
xmin = 20; xmax = 45;  dx = 0.5;
ymin = 20; ymax = 45;  dy = 0.5;
Xcoord_check_1D = 30; Ycoord_check_1D = 30; 

% interpolation parameters: 
depth_min = 10; depth_max = zmax; dz = 10; 
zq = depth_min:dz:depth_max;
InpolationMethod = 'linear';
ExtrapolationMethod = 'linear';

%% extracting data 
selected_depth = all_data(:,1) >= zmin & all_data(:,1) <= zmax;
data1 = all_data(selected_depth, [1, 2, 3, 6]);
easting_area_sutdy = data1(:, 2) >= xmin & data1(:, 2) <= xmax;
northing_area_sutdy = data1(:, 3) >= ymin & data1(:, 3) <= ymax;
area_study = easting_area_sutdy & northing_area_sutdy;
data2 = data1(area_study , :);

%% Building 3D matrices: X, Y, Z and V
z = unique(data2(:, 1)); nz = length(z);
x = unique(data2(:, 2)); nx = length(x);
y = unique(data2(:, 3)); ny = length(y);

V = reshape(data2(:, 4), [nx ny nz]);
[X, Y, Z] = meshgrid(x, y, z); 
figure; slice(X, Y, Z, V, [25 35 45], [30, 40], 100); shading interp;
colorbar; set(gca,'ZDir','reverse')

%% 1D profile - check interp methods
check_Xcoord = data2(:, 2) == Xcoord_check_1D; 
check_Ycoord = data2(:, 3) == Ycoord_check_1D;
id_check_coord = check_Xcoord & check_Ycoord;
check_data_1D = data2(id_check_coord ,4);
figure; HAxes = axes('NextPlot', 'add'); 
plot(check_data_1D, z, '*', 'Parent', HAxes); set(gca,'YDir','reverse')
title("1D profile - check interp methods ("+ Xcoord_check_1D +" , "+ Xcoord_check_1D +")°");

%% 3D interpolation 

if strcmp(type_data, 'gridded')
    % 3D griddedInterpolant 
    [X, Y, Z] = ndgrid(x, y, z); 
    F = griddedInterpolant(X, Y, Z, V);
    F.Method = InpolationMethod;
    F.ExtrapolationMethod = ExtrapolationMethod;
    [Xq, Yq, Zq] = ndgrid(x, y, zq); 
    Vq = F(Xq, Yq, Zq);

    [Xq, Yq, Zq] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zq);
    figure; slice(Xq, Yq, Zq, Vq, [25 35 45], [30, 40], [15, 90]); shading interp;
    colorbar; set(gca,'ZDir','reverse')

    check_Xcoord = Xq(:) == Xcoord_check_1D; check_Ycoord = Yq(:) == Ycoord_check_1D;
    id_check_coord = check_Xcoord & check_Ycoord;
    check_data_1D = Vq(id_check_coord);
    plot(check_data_1D, zq, 'k-.', 'Parent', HAxes); 
end 

if strcmp(type_data, 'scattered')
    % 3D scatteredInterpolant ( this method is useful to interpolate the scattered points)
    F = scatteredInterpolant(X(:), Y(:), Z(:), V(:));
    F.Method = InpolationMethod;
    F.ExtrapolationMethod = ExtrapolationMethod;
    [Xq, Yq, Zq] = meshgrid(x, y, zq); 
    Vq = F(Xq, Yq, Zq); 
    
    figure; slice(Xq, Yq, Zq, Vq, [25 35 45], [30, 40], [15, 90]); shading interp;
    colorbar; set(gca,'ZDir','reverse')

    check_Xcoord = Xq(:) == Xcoord_check_1D; check_Ycoord = Yq(:) == Ycoord_check_1D;
    id_check_coord = check_Xcoord & check_Ycoord;
    check_data_1D = Vq(id_check_coord);
    plot(check_data_1D, zq, 'k-.', 'Parent', HAxes); 
end



%% Output in txt file 
data_interp = [Zq(:), Xq(:), Yq(:), Vq(:)];
dlmwrite('data_interp.txt', data_interp, 'precision', '%8.4f', 'delimiter', '\t'); 
disp('Interpolated data is written into txt file: data_interp.txt !!! ')

