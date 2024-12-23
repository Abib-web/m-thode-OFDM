%==========================================================================
% GEI-1056 - Programme Projet de Session
% ==> programme � compl�ter
%
% par F. Nougarou
% Completer Par:
% Oumar Kone
%==========================================================================
clear all; close all; clc;

%--------------------------------------------------------------------------
% Param�tres transmission & de simulation
%--------------------------------------------------------------------------
SNR = 100;                        % niveau de bruit
M = 2048;                             % taille de la constellation QAM
Nb_SubChan_OFDM = 256;             % Nombre de sous-canaux de l'OFDM
PC = 512;                          % Longueur pr�fixe cyclique
Nb_bits = log2(M);
mode = 2;
%== Bloc C1 - Chargement de l'image =======================================
Nom_image = 'obi.jpg';
[Data_image]= Image2TrameBinaire(Nom_image,Nb_SubChan_OFDM,Nb_bits);

%==========================================================================
% Transmetteur OFDM
%==========================================================================

%-- Boucle de traitement par trames ---------------------------------------
interval = Nb_SubChan_OFDM*Nb_bits;
Nb_loop = length(Data_image) / interval;
Data_trame_256 = [];
Data_miroir =[];
Data_OFDM_all =[];
data_QAM_all = [];

for n = 1:Nb_loop
    Data_trame= Data_image((n-1)*interval+1:n*interval,1);
    
    %-- Bloc A1 - S/P -----------------------------------------------------
    Data_trame_256 = [];
    % Calcul du nombre total de trames
    longueur_trame = 256;
    nombre_trames = ceil(length(Data_trame) / longueur_trame);
    
    % Boucle pour extraire chaque trame de longueur 256
    for x = 1:nombre_trames
        indice_debut = (x - 1) * longueur_trame + 1;
        indice_fin = min(indice_debut + longueur_trame - 1, length(Data_trame));
        trame = Data_trame(indice_debut:indice_fin);
        Data_trame_256 = [Data_trame_256 trame];
    end
    %-- Bloc A2 - Modulation QAM ------------------------------------------        
    % Convertir les mots de Nb_bits en d�cimal pour la premi�re partie de la trame
    Data_trame_256_dec = bi2de(Data_trame_256);
    
    
    % Appliquer la modulation QAM pour la premi�re partie de la trame
    Data_QAM = qammod(Data_trame_256_dec, M);
        
    % Ajouter les valeurs modul�es � la liste globale
    data_QAM_all = [data_QAM_all; Data_QAM];


    %-- Bloc A3 - Miroir & IFFT -------------------------------------------
    Data_miroir = [0; Data_QAM; 0; conj(flip(Data_QAM))];
    Data_A3 = real(ifft(Data_miroir));

    %-- Bloc A4 - Ajout du Pr�fixe cycle et P/S ---------------------------
    % Extraction des PC derni�res valeurs de Data_A3
    prefixe_cyclique = Data_A3(end-PC+1:end);

    % Ajout du pr�fixe cyclique au d�but de Data_A3
    Data_A4 = [prefixe_cyclique; Data_A3];
    Data_OFDM_all = [Data_OFDM_all;Data_A4];
end



%==========================================================================
% Canal de transmission
%==========================================================================
if mode == 1
    h = 1;
elseif mode == 2
    load('canal_ofdm.mat')
    load('MES_Coef_FEQ.mat')
    figure(10);
    plot(h,'r');hold off;
    title('Mod�le du canal de transmission r�aliste')
    ylabel('Amplitude')
    xlabel('�chantillons')
    xlim([1 length(h)])
end


Data_chan = conv(h,Data_OFDM_all);
Data_chan_Noise = awgn(Data_chan, SNR);

% %==========================================================================
% % R�cepteur OFDM
% %==========================================================================
% 
Data_B3_all = [];
Data_B4_all = [];

% R�cepteur OFDM
Data_OFDM_inv_all = [];

for n = 1:Nb_loop
    % Extraire la trame de la transmission
    Data_trame_R(:,1) = Data_chan_Noise((n-1)*((Nb_SubChan_OFDM+1)*2+PC)+1:n*((Nb_SubChan_OFDM+1)*2+PC),1);

    %-- Bloc B2 - Rejet du pr�fixe ----------------------------------------
    Data_trame_noPC = Data_trame_R(PC+1:end);

    %-- Bloc B3 - FFT & miroir inverse ------------------------------------
    Data_trame_fft = fft(Data_trame_noPC);
    Data_B3 = Data_trame_fft(2:257);
    Data_B3_all = [Data_B3_all; Data_B3];

    if mode == 1
        Data_B4(:,1) = Data_B3(:,1);
    elseif mode == 2
        Data_B4(:,1) = Data_B3(:,1).*w_FEQ_2;
    end
    Data_B4_all =[Data_B4_all Data_B4];
    %-- Bloc B5 - Modulation QAM inverse ----------------------------------
    Data_QAM_out_dec1 = qamdemod(Data_B4, M);
    Data_B5 = de2bi(Data_QAM_out_dec1,Nb_bits) ;
    
    %-- Bloc B6 - P/S -----------------------------------------------------
    %Data_B6(:,1) = (reshape(Data_B5(:,:).',[],1));
    Data_B6 = vertcat(Data_B5(:,1), Data_B5(:,2),Data_B5(:,3), Data_B5(:,4),Data_B5(:,5), Data_B5(:,6),Data_B5(:,7), Data_B5(:,8), Data_B5(:,9), Data_B5(:,10), Data_B5(:,11));
    Data_OFDM_inv_all = [Data_OFDM_inv_all; Data_B6];
end


%==========================================================================
% R�sultats 
%==========================================================================

%-- Taux d'erreur sur le bit ----------------------------------------------
[errors, BER] = biterr(Data_image, uint8(Data_OFDM_inv_all));
disp(sprintf('>> Nb_erreurs = %d sur %d',errors,length(Data_image)))
disp(sprintf('>> BER = %.3f',BER*100))

%-- Remise sous forme d'une image -----------------------------------------
[Image_debut,Image_fin]= TrameBinaire2Image(Data_OFDM_inv_all);

figure(11);
subplot(1,2,1)
imshow(Image_debut)
xlabel('Image Transmisse')
title(sprintf('Images comparaisons'))
subplot(1,2,2)
imshow(Image_fin)
xlabel('Image Re�ue')
title(sprintf(' >> BER = %d',BER*100))

%==========================================================================

figure(12);
plot(real(Data_B3_all),imag(Data_B3_all),'xr');hold on
plot(real(Data_B4_all),imag(Data_B4_all),'*b');hold on;
plot(real(data_QAM_all),imag(data_QAM_all),'+k');hold off;
legend('Const. B3','Const. B4','Const. T')
grid on

%save('data_FEQ_APP.mat','data_QAM_all','Data_B3_all');

%==========================================================================
% %===========================
% %== COURBES DES VALEURS BER=
% %===========================
%====Q2.c.=========
% Valeurs de SNR et BER 
%SNR_values = [60, 45, 30, 15, 5, 0];
%BER_values = [0, 0, 2.442, 36.224, 45.576, 47.640];
%====Q2.e.=========
% M_values = [4, 64, 256, 1024];
% BER_values = [36.224, 25.918, 21.262, 17.724];
%====Q3.a.=========
% M_values = [4, 64, 256, 1024];
% BER_values =[7.017, 21.152, 27.330, 31.298];
% 
%==================================
% BER_values =[2.083, 1.219, 1.013];
% M_values = [4, 512, 2048];
% Trac� de la BER en fonction du SNR
% figure;
% plot(M_values, BER_values, '-o', 'LineWidth', 2);
% xlabel('Taille de la constellation (M)');
% ylabel('BER');
% title('BER en fonction de la taille de la constellation pour SNR = 1000 et PC=1');
% grid on;
