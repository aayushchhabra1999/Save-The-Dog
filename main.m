clear; close all; clc;

% Load the data and prepare it for further analysis
load Testdata
L=15; % spatial domain
n=64; % Fourier modes
x2=linspace(-L,L,n+1); x=x2(1:n); y=x; z=x;
k=(2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; ks=fftshift(k);

% Create mesh for spatial domain and freq domain
[X,Y,Z]=meshgrid(x,y,z);
[Kx,Ky,Kz]=meshgrid(ks,ks,ks);

% Since fluffy (the dog) is moving while ultrasound,
% we will fourier transform our signal. This will remove
% all the spatial information and leave us with just
% the freq information.

% To denoise the signal (noise due to the moving fluid),
% we will average the signal in the frequency domain.
% White noise will start shrinking and we will be able
% to find the dominant frequency in this way.
U_noisy_fft_avg = zeros(64,64,64); % Stores the avg in freq-domain
for j = 1:size(Undata,1) % go through each slice of time
    U_noisy(:,:,:) = reshape(Undata(j,:),n,n,n);
    % fft and add for avg
    U_noisy_fft_avg = U_noisy_fft_avg + fftn(U_noisy);
end
% Normalize for making average.
U_noisy_fft_avg = U_noisy_fft_avg/size(Undata,1);

% Let us now look at the data in freq domain
% so that we can find the freq of our ultrasound.
fig = figure(1);
title("Searching frequency")
iter = 1;
% only for plotting purposes
U_noisy_fft_avg_shift = fftshift(U_noisy_fft_avg);
for j = .35:.05:.6
    sub = subplot(3,2,iter);
    isosurface(Kx,Ky,Kz, ...
        abs(U_noisy_fft_avg_shift)/max(abs(U_noisy_fft_avg_shift(:))),j);
    axis([-7 7 -7 7 -7 7]); grid on; drawnow;
    text(2,4,10, strjoin(["isovalue =", j]))
    xlabel('Kx')
    ylabel('Ky')
    zlabel('Kz')
    view(30,30)
    iter = iter + 1;
end
sgtitle('Searching for ULTRASOUND FREQUENCY', 'FontSize', 12,...
    'FontWeight', 'bold');
print(fig, '-dpng', 'fig1')
%% Zooming to find out frequency

fig = figure(2);

subplot(3,1,1)
isosurface(Kx,Ky,Kz, ...
        abs(U_noisy_fft_avg_shift)/max(abs(U_noisy_fft_avg_shift(:))),j);
axis([-4 4 -2 2 -2 2]); grid on; drawnow;
title(strjoin(["isovalue =", j]))
xlabel('Kx')
ylabel('Ky')
zlabel('Kz')
view(90,0)

subplot(3,1,2)
isosurface(Kx,Ky,Kz, ...
        abs(U_noisy_fft_avg_shift)/max(abs(U_noisy_fft_avg_shift(:))),j);
axis([-4 4 -2 2 -2 2]); grid on; drawnow;
title(strjoin(["isovalue =", j]))
xlabel('Kx')
ylabel('Ky')
zlabel('Kz')
view(0,90)

subplot(3,1,3)
isosurface(Kx,Ky,Kz, ...
        abs(U_noisy_fft_avg_shift)/max(abs(U_noisy_fft_avg_shift(:))),j);
axis([-4 4 -2 2 -2 2]); grid on; drawnow;
title(strjoin(["isovalue =", j]))
xlabel('Kx')
ylabel('Ky')
zlabel('Kz')
view(0,0)

sgtitle('Zooming at isovalue = 0.6 with different cross-sections', 'FontSize', 12,...
    'FontWeight', 'bold');
print(fig, '-dpng', 'fig2')

%% Filter Design

% After averaging out most of the noise and gradually increasing 
% the isovalue, we can see that the dominant frequency.

% Now that we know the dominant frequency in the data, we will 
% build a filter and extra act the location of the stone.

% We will now find the mean freq for the filter
[~,b] = max(abs(U_noisy_fft_avg_shift(:)));
mu_x = Kx(b);
mu_y = Ky(b);
mu_z = Kz(b);

% For our purposes, let's use a gaussian filter.
fig = figure(3);
mu = [mu_x mu_y mu_z];
sig = 1;
% width of the filter is a hyperparameter:
sigma = [sig 0 0; 0 sig 0; 0 0 sig];
filter = mvnpdf([Kx(:) Ky(:) Kz(:)],mu,sigma);
filter = reshape(filter,length(Kz),length(Ky),length(Kx));
isosurface(Kx,Ky,Kz,filter)
axis([0 4 -3 2 -2 2]); grid on; drawnow;
xlabel('Kx')
ylabel('Ky')
zlabel('Kz')
view(30,30)
title('Filter Design', 'FontSize', 12,...
    'FontWeight', 'bold');
print(fig, '-dpng', 'fig3')

%% Apply filter to average

% We will now apply this filter to our avg data in the freq domain.
fig = figure(4);
U_noisy_fft_avg_shift_filter = U_noisy_fft_avg_shift.*filter;
iter = 1;
for j = 0.65:0.05:.9
    sub = subplot(3,2,iter);
    isosurface(Kx,Ky,Kz, abs(U_noisy_fft_avg_shift_filter)/max(...
        abs(U_noisy_fft_avg_shift_filter(:))),j);
    axis([-4 4 -2 2 -2 2]); grid on; drawnow;
    text(1,1,2, strjoin(["isovalue =", j]))
    xlabel('Kx')
    ylabel('Ky')
    zlabel('Kz')
    view(30,30)
    iter = iter + 1;
end
sgtitle('Filter applied on average', 'FontSize', 12,...
    'FontWeight', 'bold');
print(fig, '-dpng', 'fig4')

%% Apply filter at each time slice
% We will now apply our filter to each time slice. This will help us
% to find the path of the particle.
position = zeros(20,3); % This will store the position of the particle
for j = 1:size(Undata,1) % go through each slice of time
    U_noisy(:,:,:) = reshape(Undata(j,:),n,n,n);
    U_noisy_fft = fftn(U_noisy);
    U_noisy_fft_shift = fftshift(U_noisy_fft);
    U_noisy_fft_shift_filter = U_noisy_fft_shift.*filter;
    U = abs(ifftn(ifftshift(U_noisy_fft_shift_filter)));
    [~,b] = max(U(:));
    position(j,:) = [X(b) Y(b) Z(b)];
end

%% Plot the path of the stone
fig = figure(5);
iter = 1;
for j=5:3:20
    subplot(3,2,iter);
    plot3(position(1:j,1),position(1:j,2),position(1:j,3), 'k-'); hold on;
    plot3(position(1:j,1),position(1:j,2),position(1:j,3), 'r.');
    axis([-15 15 -15 15 -15 15]); hold on;
    view([30, 30])
    iter = iter + 1;
    title(strjoin(["After",j,"time slices"]))
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
end
sgtitle('Path of the particle.', 'FontSize', 12,...
    'FontWeight', 'bold');
print(fig, '-dpng', 'fig5')

%% Final overall plot
fig = figure(6);
plot3(position(:,1),position(:,2),position(:,3), 'k-'); hold on;
plot3(position(:,1),position(:,2),position(:,3), 'r.');
axis([-15 15 -15 15 -15 15]); hold on;
view(71.9739,-25.8661)
title("Final path of the particle")
xlabel('X')
ylabel('Y')
zlabel('Z')
print(fig, '-dpng', 'fig6')