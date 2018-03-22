function [U,As_out,Ls_out,B,W] = CVA(X,group,maxfac)
%[U,As,Ls,B,W] = CVA(X,group,maxfac)
% Performs CANONICAL VARIATES ANALYSIS
%
% INPUT VARIABLES
%
% X              = data matrix that contains m groups
%                  Dim(X) = [N x M]. All columns must be independent.
% group          = a vector containing a number corresponding
%                  to a group for every row in X. If you have 
%                  m groups there will be numbers in the range 
%                  1:m in this vector.
% maxfac         = the maximum number of CVA factors extracted
%
% OUTPUT VARIABLES
%
% U              = CVA scores matrix (Dim(U) = [N x maxfac])
%                  the eigenvalues are multiplied with each column
%                  in this matrix.
% As              = Scaled CVA loadings matrix, Dim(V) = [M x maxfac]
% eigenvals      = a vector of CVA eigenvalues
%
%
% Copyright, D.I. Broadhurst 2004
%

un = unique(group);
g = length(un)
[n,c] = size(X)
[B,W]=calc_B_and_W(X,group);
%[B,W]=TW_gen(X,group);

[A,L] = eig(B,W);

%produces a diagonal matrix L of generalized
%eigenvalues and a full matrix A whose columns are the
%corresponding eigenvectors so that B*A = W*A*L.

% need to normalize A such that Aout'*W*Aout = I
% introducing Cholesky decomposition K = T'T 
% (see Seber 1884 "Multivariate Observations" pp 270)
% At the moment
% A'*W*A = K so substituting Cholesky decoposition
% A'*W*A = T'*T ; so, inv(T')*A'*W*A*inv(T) = I
% & [inv(T)]'*A'*W*A*inv(T) = I thus, [A*inv(T)]'*W*[A*inv(T)] = I
%thus Aout = A*inv(T)
K = A'*W*A;
T = chol(K);
Aout = A*inv(T);%.*sqrt(1/(n-g));

% sort the eigenvectors w.r.t. the eigenvalues:
[dummy,idx]=sort(-diag(L));
As = Aout(:,idx'); %As sorted coefficients
Ls = L(idx);  %Ls sorted eigenvalues

%reduce to required size
As_out = As(:,1:maxfac);
Ls_out = Ls(1:maxfac);


%% Create Scores (conanical vairiates) is the matrix of scores %%%
U = X*As_out;
