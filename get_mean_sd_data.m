function [Xm,Sm,Gm,Lm,Cm] = get_mean_sd_data(X,group,label,colour)

%[Xm,Gm,Lm] = get_mean_data(X,group,label)


un = unique(group);
no_groups = length(un);
Xm = [];
Sm = [];
Gm = [];
Cm = [];
Lm = {};
for j = 1:no_groups
  idx = find(group==un(j));
  K = X(idx,:);
  Gm = [Gm;group(idx(1))];
  Lm = [Lm;label(idx(1))];
  Cm = [Cm;colour(idx(1))];
  [nn,mm]=size(K);
  if nn == 1
      Xm = [Xm;K];
      Sm = [Sm;K];
  else
  Xm = [Xm;mean(K)];
  Sm = [Sm;std(K)];
  end
end
  
    