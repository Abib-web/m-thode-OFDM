function [Image_debut,Image_fin]= TrameBinaire2Image(Data_OFDM_inv_all)
global n_zero im
Image_debut = im;

%--  Remise sous forme d'une image -----------------------
A = uint8(Data_OFDM_inv_all);
B = A(1:end-n_zero,1);
C = reshape(B,8,length(B)/8);
D = bi2de(C');
Image_fin = reshape(D, size(im,1), size(im,2),size(im,3));



