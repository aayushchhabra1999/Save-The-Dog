# Save-The-Dog
## Introduction:
Flufffy swallowed a marble. The vet suspects that it has now worked its way into the intestines. Using ultrasound, data is obtained concerning the spatial variations in a small area of the intestines where the marble is suspected to be. Unfortunately, fluffy keeps moving and the internal fluid movement through the intestines generates highly noisy data.

## Strategy:
FFT/Wavelet analysis to remove noise and detect the path of stone.

## Analysis
Since fluffy is moving in space, we will have noisy data of a spatially moving stone. To remove the spatial effects from our data, we will take the fourier transform. Now we have transitioned from the Position space to the Momentum Space (frequency domain). In this space, we will start taking the average of our data. As a result of this averaging, the white noise in the data (due to the internal fluids) will start approaching to zero and we will be able to notice a dominant frequency.
<br/>
<img src="https://github.com/aayushchhabra1999/Save-The-Dog/blob/master/fig1.png" width="70%"/>

#### Let's now zoom in at the isovalue of 0.6
<br/>
We can notice the values of Kx, Ky, Kz from the figure below.
<img src="https://github.com/aayushchhabra1999/Save-The-Dog/blob/master/fig2.png" width="70%"/>

### Filter Design
After obtaining the value of the dominant frequency, we will build a filter to extra the position of the of stone and zero out the remaining noise. At this stage, we have to make some design choices. For the implementation in my code, I have used a multivariate gaussian distribution. The mean of this filter is the frequencies that we obtained above and the covariance matrix is a hyperparameter.
<br/>
After picking the appropriate parameters, this is the filter we obtain:
<img src="https://github.com/aayushchhabra1999/Save-The-Dog/blob/master/fig3.png" width="70%"/>

### Filter applied to the average signal.
This part of the visualization doesn't specifically help with the solution to the problem but it is helpful to get insights. From the figure below, we can see that average position of the stone in the momentum space is filtered from the noise.
<img src="https://github.com/aayushchhabra1999/Save-The-Dog/blob/master/fig4.png" width="70%"/>

### Filter applied to each time signal
After appying the filter to the average signal, we have confirmed that we have a working filter. Now we will take this filter and apply it to each time slice. Then we will invert the signal back to position space and find the peak of the signal. This peak corresponds to the position of the stone.
<img src="https://github.com/aayushchhabra1999/Save-The-Dog/blob/master/fig5.png" width="70%"/>

### Predict final location of the stone for bombarding the stone with acoustic wave.
<img src="https://github.com/aayushchhabra1999/Save-The-Dog/blob/master/fig6.png" width="70%"/>
After all the time slices, this is the overall path of the stone. We will look at the coordinates of the final position from this figure and apply the acoustic wave at that location.
