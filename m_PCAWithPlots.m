function [S] = m_PCAWithPlots(M,max_fac)

args = {'X1';'X2';'Class1';'Class2';'Label1';'Label2';'Colour1';'Colour2';'UT'};

for i = 1 : 9
    if ~any(strcmp(fieldnames(M),args(i)))
        error(['Error bad model struct: no ',args{i},' field ']);
    end
end

[S.PCAscores1,S.PCAscores2,S.PCAloadings] = PCAWithPlots(M.X1,M.Class1,M.Label1,M.Colour1,M.UT,max_fac);


