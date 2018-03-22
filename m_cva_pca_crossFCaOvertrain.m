function [S] = m_cva_pca_crossFCaOvertrain(M,max_fac)

args = {'X1';'Class1';'Label1';'Colour1';'UT'};

for i = 1 : 5
    if ~any(strcmp(fieldnames(M),args(i)))
        error(['Error bad model struct: no ',args{i},' field ']);
    end
end

[S.PCAscores1,S.CVAscores1,S.PCAloadings,S.CVAloadings,S.T_loadings,S.PCAeig,S.eigenvals] = cva_pca_cross_cFCaOvertrain(M.X1,M.Class1,M.Label1,M.Colour1,M.UT,max_fac);


