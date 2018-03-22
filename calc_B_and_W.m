function [B,W] = calc_B_and_W(X,group)
% [B,W] = calc_B_and_W(X,group)
% Generates the B and W matrices used in Canonical Variates Analysis
% X contains m groups 
% group is a vector containing a number corresponding
% to a group for every row in X. If you have m groups
% there will be numbers in the range 1:m in this vector.
%
% Copyright, D.I. Broadhurst 2004
%

un = unique(group);
no_groups = length(un);
[n,m]=size(X);
mean_x = mean(X);

% Making T and W

for j = 1:no_groups
  idx = find(group==un(j));
  L = length(idx);
  Xsub = X(idx,:);
  [nn,mm]=size(Xsub);
  if nn > 1,
     mean_sub = mean(Xsub);
  else
     mean_sub = Xsub;
  end;
  
  
  % this is BJorn's code (no L*A'*A) & A calculated wrong?
  %A = K - ones(L,1)*mx;
  %C = K - ones(L,1)*zz;
  %C = K - ones(L,1)*mean(K);
  
  C = Xsub - ones(L,1)*mean_sub;
  A = mean_sub - mean_x;
  
if j > 1
    Bo = Bo + L*A'*A;
    Wo = Wo + C'*C;
  elseif j==1
    Bo = L*A'*A;
    Wo = C'*C;
  end;
end;

B = (1/(no_groups-1))*Bo;
W = (1/(n - no_groups))*Wo;