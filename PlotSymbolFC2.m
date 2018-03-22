function [out]=PlotSymbolFC2(data1,data2,x,y,col1,col2)
% PlotSymbolFC2(S.CVAscores1,S.CVAscores2,1,2,M.Colour1,M.Colour2)
%
% data = data matrix
% x & y = plot columns
% col = colour vector; Colour order: 1 red 2 brown 3 gold 4 orange 5 lt green 6 dk green 
%7 lt turq 8 dk turq 9 lt blue 10 dk blue 11 lt violet 12dk violet 13lt purple 14 dk purple 15 lt grey 
%If >15 then yellow

[r,c] = size(col1);
[rr,cc]=size(col2);
bob1 = [];
for i = 1:r,
        if col1(i) == 1
        bob1 = [bob1;[1 0 0]];
    elseif col1(i) == 2
        bob1 = [bob1;[0.5 0 0]];
    elseif col1(i) == 3
        bob1 = [bob1;[1 0.9 0]];
    elseif col1(i) == 4
        bob1 = [bob1;[1 0.3 0]];
    elseif col1(i) == 5
        bob1 = [bob1;[0 1 0.2]];
    elseif col1(i) == 6
        bob1 = [bob1;[0.2 0.8 0]];
    elseif col1(i) == 7
        bob1 = [bob1;[0 1 1]];
    elseif col1(i) == 8
        bob1 = [bob1;[0 0.9 0.9]];
    elseif col1(i) == 9
        bob1 = [bob1;[0 0.8 1]];
    elseif col1(i) == 10
        bob1 = [bob1;[0 0.5 0.8]];
    elseif col1(i) == 11
       bob1 = [bob1;[0.9 0.7 0.7]];
    elseif col1(i) == 12
        bob1 = [bob1;[0.5 0.2 0.7]];
    elseif col1(i) == 13
        bob1 = [bob1;[1 0.2 0.9]];
    elseif col1(i) == 14
        bob1 = [bob1;[0.8 0.2 0.9]];
    elseif col1(i) == 15
        bob1 = [bob1;[0.5 0.7 0.7]];        
    else
        bob1 = [bob1;[1,0.8,0]];
    end
end
bob2 = [];
for i = 1:rr,
        if col2(i) == 1
        bob2 = [bob2;[1 0 0]];
    elseif col2(i) == 2
        bob2 = [bob2;[0.5 0 0]];
    elseif col2(i) == 3
        bob2 = [bob2;[1 0.9 0]];
    elseif col2(i) == 4
        bob2 = [bob2;[1 0.3 0]];
    elseif col2(i) == 5
        bob2 = [bob2;[0 1 0.2]];
    elseif col2(i) == 6
        bob2 = [bob2;[0.2 0.8 0]];
    elseif col2(i) == 7
        bob2 = [bob2;[0 1 1]];
    elseif col2(i) == 8
        bob2 = [bob2;[0 0.9 0.9]];
    elseif col2(i) == 9
        bob2 = [bob2;[0 0.8 1]];
    elseif col2(i) == 10
        bob2 = [bob2;[0 0.5 0.8]];
    elseif col2(i) == 11
       bob2 = [bob2;[0.9 0.7 0.7]];
    elseif col2(i) == 12
        bob2 = [bob2;[0.5 0.2 0.7]];
    elseif col2(i) == 13
        bob2 = [bob2;[1 0.2 0.9]];
    elseif col2(i) == 14
        bob2 = [bob2;[0.8 0.2 0.9]];
    elseif col2(i) == 15
        bob2 = [bob2;[0.5 0.7 0.7]];        
    else
        bob2 = [bob2;[1,0.8,0]];
    end
end

for i=1
plot(data1(i,x),data1(i,y),'^','MarkerFaceColor',bob1(i,:),'MarkerEdgeColor',bob1(i,:),'MarkerSize',10);
end
hold;


for i=2:r
plot(data1(i,x),data1(i,y),'^','MarkerFaceColor',bob1(i,:),'MarkerEdgeColor',bob1(i,:),'MarkerSize',10);
end

for i=1:rr
plot(data2(i,x),data2(i,y),'^','MarkerEdgeColor',bob2(i,:),'MarkerSize',10);
end

ylabel('PC-CV 2','FontSize', 14);
xlabel('PC-CV 1','FontSize', 14);

end
