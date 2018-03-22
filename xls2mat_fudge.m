function [S,E] = xls2mat_fudge(filename,meta_sheet,t1,l)

[S,E] = xls2struct6(filename,meta_sheet);
%[t1,label] = load_matrix_xls(filename,data_sheet);
label = num2cell(l);
[r,c] = size(t1);
[rr,cc] = size(E);

if(rr ~= r)
    error(['Dimension mismatch. Check the dimensions of your source Excel sheet!:',int2str(rr),' :',int2str(r)]); 
end

tt = num2cell(t1,2);

S.X = tt;

for i = 1:r
    S.Xlabel{i} = label;
    E(i).X = t1(i,:);
    E(i).Xlabel = label;
end