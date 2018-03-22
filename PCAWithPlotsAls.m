function [pp,tt,la,TSQ,pr] = PCAWithPlotsAls(XT,YT,LT,CT,ut,max_fac)

%[COEFF, SCORE, LATENT, TSQUARED, EXPLAINED] = pca(X) returns a vector
 %   containing the percentage of the total variance explained by each
  %  principal component. tt is SCORES


%[S.PCAscores,S.PCAloadings,S.percentvar] = PCAWithPlots(M.X1,M.Class1,M.Label1,M.Colour1,M.UT,6);
%function [XTtt,XVtt,UT,UV,pp,V,load,pr,eigenvals] = PCAWithPlots(XT,YT,LT,CT,ut,max_fac)

% [PCAT_s,PCAV_s,DFAT_s,DFAV_s,PCA_l,DFA_l,pp] = dfa_pca_cross_c(XT,XV,YT,YV,LT,LV,CT,CV,ut)
% XT, YT, LT & CT= training X, groups for training X, lables for training X, colour for training X.
% XV & YV = validation X, groups for validation X, lables for validation X, colour for validation X.
% ut = variable labels
% max_fac = max number of PCs to use

% PCAT_s = PCA training scores
% DFAT_s = DFA training scores
% DFAV_s = DFA validation scores

% PCAV_s = PCA validation scores
% PCA_l,DFA_l,pp = PCA loadings , DFA loadings , & combined (overall) loadings

% for more help see david.broadhurst@manchester.ac.uk


label_YT = LT;
%label_YV = LV;


m = mean(XT);
%[a,b] = size(XV);
%XVc =  XV - ones(a,1)*m;

[pp,tt,la,TSQ,pr] = pca(XT,'Algorithm','als','Centered','off','NumComponents',max_fac);

pr=round(pr, 0, 'decimal');

l=length(pr);
pr(1,2)=pr(1,1);
for i=2:l
pr(i,2)=(pr(i,1)-pr((i-1),1))
end
    
    %figure;
    %plot(UT(:,1),UT(:,2),'k.','MarkerFaceColor','k');
    plot_colourFC(tt,label_YT,1,2,CT);
    %text(UT(:,1),UT(:,2),label_YT);
    %label = int2str(fac); 
    %label = num2str(fac);
    
    title(['FC3']);
    hold on;
    %plot_colour_boxFC(UV,label_YV,1,2,CV);
    
    %plot(UV(:,1),UV(:,2),'rx');
    %text(UV(:,1),UV(:,2),label_YV);
    %legend('test set = *');
    ylabel('PC2 ');
    xlabel('PC1 ');
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
