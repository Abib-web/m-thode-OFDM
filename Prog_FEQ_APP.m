%==========================================================================
% GEI-1056 - Programme FEQ - Projet de Session
% ==> programme à  compléter
%
% par F. 
%Completer Par:
% Oumar Kone
%==========================================================================
clear all; close all; clc;
%-- Chargement de vos données «data_QAM_all» et «data_B3_all»
load('data_FEQ_APP.mat');

%-- Mise sous la forme 256 lignes (ou sous-canaux) x Nb_loop colonnes
Data_B3_all = reshape(Data_B3_all,256,length(Data_B3_all)/256);
data_QAM_all = reshape(data_QAM_all,256,length(data_QAM_all)/256);

%== Calcul des coefficient du FEQ - Méthode NLMS ==========================
Nb_SubChan_OFDM = size(data_QAM_all,1);       % nombre de sous-canaux
Nb_iter = size(data_QAM_all,2);               % nombre d'iterations

%- Initialiation ----------------------------------------------------------
w_FEQ_APP = zeros(Nb_SubChan_OFDM,Nb_iter);   % Initialisation des coefficients 
mu = 0.01;
Output_NLMS = zeros(Nb_SubChan_OFDM,Nb_iter);  % Initialisation de la sortie
Erreur_NLMS = zeros(Nb_SubChan_OFDM,Nb_iter);  % Initialisation de l'erreur

%-- Boucle d'apprentissage de la méthode NLMS -----------------------------
for n = 1:Nb_iter               % boucle des itÃ©rations
    for i = 1:Nb_SubChan_OFDM   % boucle des sous-canaux
        %-- Calcul de la sortie «Output_NLMS»
        Output_NLMS(i, n) = conj(w_FEQ_APP(i, n)) * Data_B3_all(i, n);
        % -- Calcul de l'erreur «Erreur_NLMS»
        Erreur_NLMS(i, n) = data_QAM_all(i,n) - Output_NLMS(i, n);
        
        % -- Calcul de la mise à jour des coefficient 
        w_FEQ_APP(i,n+1) = w_FEQ_APP(i,n) + mu * conj(Erreur_NLMS(i,n)) * (Data_B3_all(i,n) / norm(Data_B3_all(i,n))^2);
    end
end

%-- Affichage de l'erreur de convergence ----------------------------------
figure(100);plot((Erreur_NLMS.*conj(Erreur_NLMS))')

%-- Choix des Coefficients ------------------------------------------------
w_FEQ_2 = conj(w_FEQ_APP(:,end)); % le conjugué ici vite de l'appliquer dans le programme principal

%-- sauvegarde des Coefficients -------------------------------------------
save('MES_Coef_FEQ.mat','w_FEQ_2')
%==========================================================================