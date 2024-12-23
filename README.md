# Projet de Session GEI-1056 - Systèmes de Télécommunications

Ce projet porte sur la mise en œuvre et l'analyse d'un égaliseur fréquentiel (FEQ) utilisant la méthode **NLMS (Normalized Least Mean Squares)** dans le cadre d'une transmission OFDM (Orthogonal Frequency Division Multiplexing).

## Objectifs du projet
- Implémenter un algorithme d'égalisation fréquentielle pour améliorer la qualité de la transmission dans un système OFDM.
- Analyser les performances de l'égaliseur en termes de convergence et de réduction des erreurs.
- Étudier les paramètres influençant la performance du système, tels que le pas d'apprentissage (*mu*) et le nombre d'itérations.

## Fonctionnalités principales
1. **Chargement des données** : Lecture des données d'entrée nécessaires pour simuler un système OFDM (`data_QAM_all` et `Data_B3_all`).
2. **Méthode NLMS** :
   - Calcul des coefficients de l'égaliseur fréquentiel.
   - Mise à jour adaptative des coefficients pour minimiser l'erreur.
3. **Visualisation des performances** :
   - Affichage de l'évolution de l'erreur de convergence.
   - Sauvegarde des coefficients optimaux pour utilisation future.
4. **Simulation MATLAB** :
   - Implémentation complète en MATLAB avec des données simulées et des résultats affichés graphiquement.

## Structure du projet
- **Fichiers MATLAB principaux** :
  - `Prog_FEQ_APP.m` : Script principal contenant l'implémentation de l'algorithme NLMS.
  - `data_FEQ_APP.mat` : Données d'entrée nécessaires pour la simulation.
  - `MES_Coef_FEQ.mat` : Fichier de sortie contenant les coefficients optimaux après apprentissage.
- **Données de simulation** :
  - `Data_B3_all` : Données OFDM simulées.
  - `data_QAM_all` : Constellation QAM utilisée comme référence.

## Utilisation
1. **Prérequis** :
   - Installer MATLAB.
   - Télécharger tous les fichiers du projet et les placer dans le même répertoire de travail.
2. **Exécution** :
   - Ouvrir MATLAB et définir le dossier du projet comme répertoire de travail.
   - Exécuter le fichier `Prog_FEQ_APP.m`.
3. **Résultats** :
   - Visualisation de l'évolution de l'erreur de convergence dans une figure MATLAB.
   - Génération et sauvegarde des coefficients optimaux dans `MES_Coef_FEQ.mat`.

## Exemple de code
```matlab
% Chargement des données
load('data_FEQ_APP.mat');

% Initialisation des paramètres
mu = 0.01; % Pas d'apprentissage
Nb_iter = size(data_QAM_all, 2); % Nombre d'itérations
Nb_SubChan_OFDM = size(data_QAM_all, 1); % Nombre de sous-canaux

% Boucle NLMS
for n = 1:Nb_iter
    for i = 1:Nb_SubChan_OFDM
        % Calcul de l'erreur et mise à jour des coefficients
        Output_NLMS(i, n) = conj(w_FEQ_APP(i, n)) * Data_B3_all(i, n);
        Erreur_NLMS(i, n) = data_QAM_all(i,n) - Output_NLMS(i, n);
        w_FEQ_APP(i,n+1) = w_FEQ_APP(i,n) + mu * conj(Erreur_NLMS(i,n)) * (Data_B3_all(i,n) / norm(Data_B3_all(i,n))^2);
    end
end
