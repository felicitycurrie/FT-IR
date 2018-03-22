function [XTtt,UT,pp,V,load,pr,eigenvals] = cva_pca_cross_cFCaOvertrain(XT,YT,LT,CT,ut,max_fac)


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


m = nanmean(XT);
%[a,b] = size(XV);
%XVc =  XV - ones(a,1)*m;
%[XTttmax,ppmax,prmax] = PCA(XT,max_fac);
%for non-scaled data:
%[ppmax,XTttmax,la,TSQ,prmax] = pca(XT,'Algorithm','als','Centered','off','NumComponents',max_fac);
%for autoscaled data:
[ppmax,XTttmax,la,TSQ,prmax] = pca(XT,'Algorithm','als','Centered','off','NumComponents',max_fac);

ppmax=ppmax';
fac = 2;

while fac,
    fac = input('Number of PC scores to use: ');
    if(fac == 0)
        continue;
    end
    if (fac < 2) | (fac > max_fac)
        warndlg(['Number of PCs must be > 2 and < ',int2str(max_fac)]);
        continue;
    end
    XTtt = XTttmax(:,1:fac);
    
    pp = ppmax(1:fac,:);
    pr = prmax(1:fac,:);
    
    %[UT,V,eigenvals] = DFA(XTtt,YT,3);
    %[UT,V,eigenvals,dummyB,dummyW] = CVA(XTtt,YT,3);
    [UT,V,eigenvals] = cva(XTtt,YT,5);
    %XVtt = XVc*pp';
   % UV = XVtt*V;
    %UV = UV*diag(eigenvals);
    %UV = real(UV);
    
    %figure;
    %plot(UT(:,1),UT(:,2),'k.','MarkerFaceColor','k');
    plot_colourFC(UT,label_YT,1,2,CT);
    %text(UT(:,1),UT(:,2),label_YT);
    label = int2str(fac); 
    title(['CVA model built and cross validated using the first ',label, ' PCA scores']);
    hold on;
   % plot_colour_boxFC(UV,label_YV,1,2,CV);
    
    %plot(UV(:,1),UV(:,2),'rx');
    %text(UV(:,1),UV(:,2),label_YV);
    %legend('test set = *');
    ylabel('CV 2');
    xlabel('CV 1');
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

end
