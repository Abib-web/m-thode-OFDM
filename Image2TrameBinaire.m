function [Data_image]= Image2TrameBinaire(nom_image,Nb_SubChan_OFDM,Nb_bits)
global n_zero im
file_in = [];
while isempty(file_in) 
    file_in = (nom_image);
    if exist([pwd '/' file_in],'file')~=2
        fprintf ...
            ('"%s" does not exist in current directory.\n', file_in);
        file_in = [];
    end
end
%-- Mise sous forme série double de l'Image
im = imread(file_in);
Image_parfaite_vect = reshape(im,[],1);
data_In = (Image_parfaite_vect)';
data_In_b = de2bi(data_In);
Data_image = reshape(data_In_b',1,[]);

% ----Padder 0 des block OFDM à envoyer------------------------------------
lengthe=length(Data_image);
n_zero = 0;
while(mod(length(Data_image),((Nb_SubChan_OFDM)*Nb_bits))~=0)
    Data_image=[Data_image 0];
    n_zero = n_zero + 1;
end
Data_image = Data_image.';
