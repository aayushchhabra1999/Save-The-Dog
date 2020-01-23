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
% fig2 is zoomed version of fig1 subplot 3,2,6
%%
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
% the isovalue, we can see that the dominant frequency occurs at
% Kx = 2, Ky = -1, Kz = 0

% Now that we know the dominant frequency in the data, we will 
% build a filter and extra act the location of the stone.

% For our purposes, let's use a gaussian filter.
fig = figure(3);
mu = [2 -1 0];
% width of the filter is a hyperparameter:
sigma = [0.001 0 0; 0 0.001 0; 0 0 0.001];
filter = mvnpdf([Kx(:) Ky(:) Kz(:)],mu,sigma);
filter = reshape(filter,length(Kz),length(Ky),length(Kx));
isosurface(Kx,Ky,Kz,filter)
axis([0 4 -3 2 -2 2]), grid on, drawnow
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
U_noisy_fft_avg_filter = U_noisy_fft_avg

%% Apply filter at each time

% We will now apply our filter to each time slice. This will help us
% to find the path of the particle.








