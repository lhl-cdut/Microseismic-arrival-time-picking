This repository contains a collection of codes for picking  the first arrival of P waves from high-noise microseismic recording. These codes are as follows:

1. data
====DATA_Real.mat  %Field real microseismic data
====Y_Bluenoise.mat   %Synthetic microseismic data with blue noise and SNR is -15dB
====Y_GaussianNoising.mat  %Synthetic microseismic data with Gaussian white noise and SNR is -15dB
====Pure_E.sgy   %Pure forward signal

2. func
% Contains all calling functions

3. picker.m  
% Picking results of synthetic microseismic recordings and compare the picking effects of new methods, AIC (Ori) and AIC (Pre) （(Ori) means the original data without the denoising procedure, and (Pre) represents the data that have been preprocessed with the denoising.）

4. Time_consumption_comparison.m
% Time consumption comparison of five different picking methods(STA/LTA(O), STA/LTA(A), M-AIC(O), M-AIC(A), New Method)

Short Description：
In this study, we implement a method for automatically identifying P-wave arrival-time in three-component microseismic data with high-noise. The algorithm efficiently combines ensemble empirical mode decomposition (EEMD), sample entropy (SampEn) and Akaike information criterion (AIC) to improve theaccuracy of the P-wave arrival-time picking. The main process of this method is as follows:
First, the EEMD algorithm is employed to decompose microseismic recording into a series of intrinsic mode functions (IMFs). Then, the SampEn value of each IMF is calculated and adopted to set a proper threshold for selecting the IMF, the selected IMFs are reconstructed to distinguish the noise and the useful signal. Finally, we apply the AIC picking algorithm to the appropriate data segment of the reconstructed signal, which can produce a reliable onset time estimation for the microseismic datasets. 

Result:
Experiments on synthetic microseismic data with low signal-to-noise ratio show that the new method can obtain the picking error in 1-3 sampling intervals. Moreover, this method can keep higher stability than other common collectors when applied to synthetic microseismic records with different signal-to-noise ratios. The validity and reliability of this method are further proved by the application in the real microseismic records. Although the new method consumes more time than other common collectors, considering the performance of modern computer platforms, the time cost may not limit the application of the proposed automatic arrival-time picking .