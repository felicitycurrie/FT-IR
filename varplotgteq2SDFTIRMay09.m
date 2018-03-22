%function [out,outabs,outsort,MetabolitesSort,outcell] = varplotgteq2SDFTIR(data,MetaboliteID,MetaboliteNames)
%
%This produces a stem plot of DFloadings vs a wavenumber index for the dataset eg 
%1-834 bins or 1-834 wavenumbers .
%The loadings over a selected level are labelled with the wavenumber (vector). 
%
%Outsort is a sorted list of the wavenumber with loadings over the
%selected level and is sorted by absolute loading amplitude in decreasing
%order - enabling, say, the 100 wavenumbers contributing most to the
%discrimination to be selected consistently.

% The 5 columns in [outcell] are 1-i, the index in the data matrix, 2-the
% wavenumberidx for i, 3-the DF loading for i, 4-the sorted absolute value of
% the DF loading, 5-the wavenumber

%what to put in:
%ut834              is a vector of wavenumbers(number)to appear on the
%                   X-axis and in outsort
%data               is the T_loadings for CV1 from the PC-CVA (832) (plus 2 %zeros (834))
%for the plot) for the FTIR spectrum to calculate the mean. Adding 2 zeros
% doesn't change the mean or SD of the loadings
%WavenumberID       is the numeric ID for the wavenumber eg vector 1-834
%Wavenumber         is a vector of wavenumbers (string) to appear on the plot
% 
%level              reset by the user after viewing the first plot - loadings
%                   greater than this level are labelled in the plot and
%                   output in out, outcell etc - set to 2SD from
%                   the mean in the method
%
%NOTE1              The X-axis on the plot needs to be reversed using Axis
%                   properties, the datapoint labels are reversed correctly
%                   along with the data (!)
%
%NOTE2              Outsort can be copied and pasted into Excel and text
%                   converted to columns for a record of the most significant
%                   wavenumbers
%
%NOTE3              The display of numbers in Matlab can be changed to 5
%                   significant figures rather than scientific notation using
%                   Format short g
%
%NOTE4              You need to produce and hold the first plot(eg a
%                   spectrum for exposed cells) before running this method
%NOTE5              change the scaling factor in line 65 to produce plots
%where loadings are roughly equivalent height to the FT-IR spectra

%Felicity Currie April 2006

function [out,outabs,outsort,P,Q,R] = varplotgteq2SDFTIRMay09(ut834,data,WavenumberID,Wavenumber)

%stem(ut834,data,'x');
[r[r,c] = size(data);
out=[];
P=abs(data);
Q=mean(P);
R=std(P);
level=2*R
SigLoad=[];

  for i=1:r
        if abs(data(i))>=level
           SigLoad=[SigLoad ; i abs(data(i))];
            
            
            stem(ut834(i),(data(i)*2),'x');
            out=[out;i WavenumberID(i,:) ut834(i,:) data(i,:)];
            %text(ut834(i),data(i),[' \leftarrow',(Wavenumber(i,:))],'HorizontalAlignment','left','FontSize',6);
        end
    end

ylabel('Loading PC-CV1','FontSize', 14);
xlabel('Wavenumber','FontSize', 14);
%title(['PC-DF1 Loadings for cells exposed to Propranolol']);
outabs=[out abs(out(:,4))];
outsort = flipud(sortrows(outabs,5));

end