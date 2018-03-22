function [S] = m_cva_pca_crossFCa(M,max_fac)

args = {'X1';'X2';'Class1';'Class2';'Label1';'Label2';'Colour1';'Colour2';'UT'};

for i = 1 : 9
    if ~any(strcmp(fieldnames(M),args(i)))
        error(['Error bad model struct: no ',args{i},' field ']);
    end
end

[S.PCAscores1,S.PCAscores2,S.CVAscores1,S.CVAscores2,S.PCAloadings,S.CVAloadings,S.T_loadings,S.PCAeig,S.eigenvals] = cva_pca_cross_cFCa(M.X1,M.X2,M.Class1,M.Class2,M.Label1,M.Label2,M.Colour1,M.Colour2,M.UT,max_fac);


