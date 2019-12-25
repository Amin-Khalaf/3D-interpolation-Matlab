%% download original data : depths from 25 to 100 km with 25 km spacing 
data0 = load('original_data_25_100km_2016.txt');
% we need only columns: 1-depths, 2-lon, 3-lat, and 6-dVs(%)
data1 = data0(:, [1, 2, 3, 6]);
% select the data where our study area (20 - 45°) northing and easting
Xcoord_check_1D = 30; Ycoord_check_1D = 30; 
xmin = 20; xmax = 45; dx = 0.5;
ymin = 20; ymax = 45; dy = 0.5;
easting_area_sutdy = data1(:, 2) >= xmin & data1(:, 2) <= xmax;
northing_area_sutdy = data1(:, 3) >= ymin & data1(:, 3) <= ymax;
area_study = easting_area_sutdy & northing_area_sutdy;
data2 = data1(area_study , :);

%% separating data at each depth = 25, 50 ... and so on 
nx = 51; 
depth_25 = data2(:, 1) == 25;
test_data = sortrows(data2(depth_25, :), 2);
dVs_25 = reshape(test_data(:, 4), nx, []);
X25 = reshape(test_data(:, 2), nx, []);
Y25 = reshape(test_data(:, 3), nx, []);
figure; imagesc([xmin xmax],[ymin ymax],flipud(dVs_25)); colorbar; 
set(gca,'YDir','normal')

depth_50= data2(:, 1) == 50;
test_data = sortrows(data2(depth_50, :), 2);
dVs_50 = reshape(test_data(:, 4), nx, []);
X50 = reshape(test_data(:, 2), nx, []);
Y50 = reshape(test_data(:, 3), nx, []);
figure; imagesc([xmin xmax],[ymin ymax],flipud(dVs_50)); colorbar; 
set(gca,'YDir','normal')

depth_75= data2(:, 1) == 75;
test_data = sortrows(data2(depth_75, :), 2);
dVs_75 = reshape(test_data(:, 4), nx, []);
X75 = reshape(test_data(:, 2), nx, []);
Y75 = reshape(test_data(:, 3), nx, []);
figure; imagesc([xmin xmax],[ymin ymax],flipud(dVs_75)); colorbar; 
set(gca,'YDir','normal')

depth_100 = data2(:, 1) == 100;
test_data = sortrows(data2(depth_100, :), 2);
dVs_100 = reshape(test_data(:, 4), nx, []);
X100 = reshape(test_data(:, 2), nx, []);
Y100 = reshape(test_data(:, 3), nx, []);
figure; imagesc([xmin xmax],[ymin ymax],flipud(dVs_100)); colorbar; 
set(gca,'YDir','normal')

disp(isequal(X25, X50, X75, X100) & isequal(Y25, Y50, Y75, Y100)) 

%% building 3D matrix
z = unique(data2(:,1));
all_data = {dVs_25, dVs_50, dVs_75, dVs_100};
dVs_3D = cat(3, all_data{:});
X_3D = repmat(X25, [1 1 length(z)]);
Y_3D = repmat(Y25, [1 1 length(z)]);
Z_3D = reshape(repmat(z, [size(X25, 1)* size(X25, 2), 1]), [size(X25, 1), size(X25, 2), length(z)]);
[X, Y, Z] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, z); 
figure; slice(X, Y, Z, dVs_3D, [25 35 45], [30, 40], 50); shading interp;
colorbar; set(gca,'ZDir','reverse')

check_Xcoord = data2(:, 2) == Xcoord_check_1D; check_Ycoord = data2(:, 3) == Ycoord_check_1D;
id_check_coord = check_Xcoord & check_Ycoord;
check_data_1D = data2(id_check_coord ,4);
figure; HAxes = axes('NextPlot', 'add'); 
plot(check_data_1D, z, '*', 'Parent', HAxes); set(gca,'YDir','reverse')
title('1D profile - check interp methods');

%% method 1: 3D interpolation (no extrapolation with linear method !!) 
zq = 10:10:100;
[Xq, Yq, Zq] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zq); 
Vq = interp3(X, Y, Z, dVs_3D, Xq, Yq, Zq, 'makima');
figure; slice(Xq, Yq, Zq, Vq, [25 35 45], [30, 40], [15, 90]); shading interp;
colorbar; set(gca,'ZDir','reverse')

check_Xcoord = Xq(:) == Xcoord_check_1D; check_Ycoord = Yq(:) == Ycoord_check_1D;
id_check_coord = check_Xcoord & check_Ycoord;
check_data_1D = Vq(id_check_coord);
plot(check_data_1D, zq, 'ro-', 'Parent', HAxes);

%% method 2: 3D griddedInterpolant 
[X, Y, Z] = ndgrid(xmin:dx:xmax, ymin:dy:ymax, z); 
F = griddedInterpolant(X, Y, Z, dVs_3D);
F.Method = 'linear';
F.ExtrapolationMethod = 'linear';
zq = 10:10:100;
[Xq, Yq, Zq] = ndgrid(xmin:dx:xmax, ymin:dy:ymax, zq); 
Vq = F(Xq, Yq, Zq);

[Xq, Yq, Zq] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zq);
figure; slice(Xq, Yq, Zq, Vq, [25 35 45], [30, 40], [15, 90]); shading interp;
colorbar; set(gca,'ZDir','reverse')

check_Xcoord = Xq(:) == Xcoord_check_1D; check_Ycoord = Yq(:) == Ycoord_check_1D;
id_check_coord = check_Xcoord & check_Ycoord;
check_data_1D = Vq(id_check_coord);
plot(check_data_1D, zq, 'k-.', 'Parent', HAxes);

%% method 3: 3D scatteredInterpolant ( this method is useful to interpolate the scattered points)
% F = scatteredInterpolant(X(:), Y(:), Z(:), dVs_3D(:));
% F.Method = 'linear';
% F.ExtrapolationMethod = 'linear';
% zq = 10:10:100;
% [Xq, Yq, Zq] = meshgrid(xmin:dx:xmax, ymin:dy:ymax, zq); 
% Vq = F(Xq, Yq, Zq);
% figure; slice(Xq, Yq, Zq, Vq, [25 35 45], [30, 40], [15, 90]); shading interp;
% colorbar; set(gca,'ZDir','reverse')

%% Output in txt file 
data_interp = [Zq(:), Xq(:), Yq(:), Vq(:)];
disp('Interpolated data is written into txt file: data_interp.txt !!! ')
dlmwrite('data_interp.txt', data_interp, 'precision', '%8.4f', 'delimiter', '\t'); 


