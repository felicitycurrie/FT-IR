function [tt,pp,pr] = PCAWith3dPlots(XT,YT,LT,CT,ut,max_fac)
%function [XTtt,XVtt,UT,UV,pp,V,load,pr,eigenvals] = PCAWithPlots(XT,YT,LT,CT,ut,max_fac)

% [PCAT_s,PCAV_s,DFAT_s,DFAV_s,PCA_l,DFA_l,pp] = dfa_pca_cross_c(XT,XV,YT,YV,LT,LV,CT,CV,ut)
% XT, YT, LT & CT= training X, groups for training X, lables for training X, colour for training X.
% XV & YV = validation X, groups for validation X, lables for validation X, colour for validation X.
% ut = variable labels
% max_fac = max number of PCs to use

% PCAT_s = PCA training scores
% PCAV_s = PCA validation scores
% DFAT_s = DFA training scores
% DFAV_s = DFA validation scores

% PCA_l,DFA_l,pp = PCA loadings , DFA loadings , & combined (overall) loadings

% for more help see david.broadhurst@manchester.ac.uk


label_YT = LT;
%label_YV = LV;


m = mean(XT);
%[a,b] = size(XV);
%XVc =  XV - ones(a,1)*m;
[tt,pp,pr] = PCA(XT,max_fac);


    
    %figure;
    %plot(UT(:,1),UT(:,2),'k.','MarkerFaceColor','k');
    plot3dcolourFC(tt,label_YT,1,2,3,CT);
    %text(UT(:,1),UT(:,2),label_YT);
    %label = int2str(fac); 
    %label = num2str(fac);
    
  
title(['PCA for 29 Known Antimalarial Compounds 48h']);
xlabel(['PC 1 - 47.8% explained variance']);
ylabel(['PC 2 - 16.1% explained variance']);
zlabel(['PC 3 - 7.6% explained variance']);
grid on
hold on;
    %plot_colour_boxFC(UV,label_YV,1,2,CV);
    
    %plot(UV(:,1),UV(:,2),'rx');
    %text(UV(:,1),UV(:,2),label_YV);
    %legend('test set = *');

    %fac = input('Number of PC scores to use: ');
    hold off;
end

%load = pp'*V;
%[rr,cc] = size(pp);


%h = figure;
%step = 5;
%while step > 0

%aa = [1:step:cc];
%a = ut(aa);

%plot(load(:,1),load(:,2),'c')
%text(load(aa,1),load(aa,2),a,'color', 'k')
%ylabel('CV 2');
%xlabel('CV 1');
%step = input('Number of label steps to use: ');

%end
