avg_Dimensions=60;

% avg hma parameters
[hma_nums_avg_0,hma_dens_avg_0]=hma(avg_Dimensions/2);
[hma_nums_avg_1,hma_dens_avg_1]=hma(floor(avg_Dimensions));
[hma_nums_avg_2,hma_dens_avg_2]=hma(floor(sqrt(avg_Dimensions)));

% deviation hma parameters
deviation_Dimensions=60;
[hma_nums_deviation_0,hma_dens_deviation_0]=hma(deviation_Dimensions/2);
[hma_nums_deviation_1,hma_dens_deviation_1]=hma(floor(deviation_Dimensions));
[hma_nums_deviation_2,hma_dens_deviation_2]=hma(floor(sqrt(deviation_Dimensions)));