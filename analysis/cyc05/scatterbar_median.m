% scatterbar_median
% Mohammad Shams <m.shamsahmar@gmail.com>
% January 2025

function xs = scatterbar_median(A, ...
    szMedianLine,lwMedianLine, ...
    szMarker,alphaMarker,spreadMarker)

% A: a cell of cetegories

A = mat2cell(A, size(A,1), ones(1, size(A,2)));

nCat = numel(A); % number of categories

if nargin == 1    
    szMedianLine = .4; % line length for mean
    lwMedianLine = 4;
    szMarker = 70; % marker size
    alphaMarker = .2;
    spreadMarker = .05; % standard deviation of scatters in each category
end

hold on
for icat = 1:nCat    
    rng default
    n = numel(A{icat});
    x = randn(n,1)*spreadMarker + icat;
    xs(:,icat) = x;
    
    scatter(x,A{icat}, ...
        szMarker,'k','o','filled', ...
        'markerfacealpha',alphaMarker);
    line([ ...
        icat-szMedianLine icat+szMedianLine], ...
        [median(A{icat}) median(A{icat})],...
        'color','k','linewidth',lwMedianLine);
end

xlim([0 nCat+1])
set(gca,'xtick',1:nCat)
end