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

