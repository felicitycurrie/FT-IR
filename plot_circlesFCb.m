function plot_circlesFCb(S,M)
% plot_colour(data,info,x,y,col)
%
% data = data matrix
% info = single column info file
% x & y = plot columns
% col = colour vector; Colour order: 1 red 2 brown 3 gold 4 orange 5 lt green 6 dk green 
%7 lt turq 8 dk turq 9 lt blue 10 dk blue 11 lt violet 12dk violet 13lt purple 14 dk purple 15 lt grey 
%If >15 then yellow

%[Xm,Sm,Gm,Lm,Cm] = get_mean_sd_data(S.CVAscores1,M.Class1,M.Label1,M.Colour1)

[Xm,Sm,Gm,Lm,Cm] = get_mean_sd_data(S.CVAscores1,M.Class1,M.Label1,M.Colour1)

col=Cm
[r,c] = size(col);
bob = [];
for i = 1:r,
        if col(i) == 1
        bob = [bob;[1 0 0]];
    elseif col(i) == 2
        bob = [bob;[0.5 0 0]];
    elseif col(i) == 3
        bob = [bob;[1 0.9 0]];
    elseif col(i) == 4
        bob = [bob;[1 0.3 0]];
    elseif col(i) == 5
        bob = [bob;[0 1 0.2]];
    elseif col(i) == 6
        bob = [bob;[0.2 0.8 0]];
    elseif col(i) == 7
        bob = [bob;[0 1 1]];
    elseif col(i) == 8
        bob = [bob;[0 0.9 0.9]];
    elseif col(i) == 9
        bob = [bob;[0 0.8 1]];
    elseif col(i) == 10
        bob = [bob;[0 0.5 0.8]];
    elseif col(i) == 11
       bob = [bob;[0.9 0.7 0.7]];
    elseif col(i) == 12
        bob = [bob;[0.5 0.2 0.7]];
    elseif col(i) == 13
        bob = [bob;[1 0.2 0.9]];
    elseif col(i) == 14
        bob = [bob;[0.8 0.2 0.9]];
    elseif col(i) == 15
        bob = [bob;[0.5 0.7 0.7]];        
    else
        bob = [bob;[1,0.8,0]];
    end

end

%h = figure;
%plot(data(:,x),data(:,y),'w.')

rr=size(Cm)
for ii = 1:rr
%circle(2.15,Xm(ii,1),Xm(ii,2),bob(ii,:),0.05,100);%90% samples lie within this circle
%circle(2.45,Xm(ii,1),Xm(ii,2),bob(ii,:),0.05,100);%95% samples lie within this circle
circle(3.03,Xm(ii,1),Xm(ii,2),bob(ii,:),0.05,100);%99% samples lie within this circle


plot(Xm(ii,1),Xm(ii,2),'x','color',bob(ii,:));
%if isa(info,'cell')
 %   for i = 1:r 
  %      text(data(i,x),data(i,y),info{i},'color',bob(i,:));
        %text(data(i,x),data(i,y),strcat(info(i,:),'^*'),'color',bob(i,:));
   % end
%elseif isa(info,'char')
 %   for i = 1:r 
  %      text(data(i,x),data(i,y),info(i,:),'color',bob(i,:)); 
   % end
    %elseif isa(i,'int')
%else
 %   l = int2str(info);
  %  for i = 1:r 
   %     text(data(i,x),data(i,y),l(i,:),'color',bob(i,:));
    %end
end




