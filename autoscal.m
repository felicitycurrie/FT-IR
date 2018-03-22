function X = autoscal(X)
%  Y = autoscal(X)
% Performs autoscaling of the columns in X
%
% Copyright (c) 1996, B.K. Alsberg
%

[n,m]=size(X);

s = std(X);
X = X - ones(n,1)*mean(X);

for i =1:n
 X(i,:) = X(i,:)./s;
end;


