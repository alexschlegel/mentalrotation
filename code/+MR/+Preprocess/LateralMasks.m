function cAllMasks = LateralMasks(cMasks, cHemi)
% MR.Preprocess.LateralMasks
%
% Description: combine labels for mask area and hemisphere into a
% cell of hemisphere-specific mask labels.
%
% Syntax: cAllMasks = LateralMasks(cMasks, cHemi)
%
% In:
%   cMasks: cell of mask area labels
%   cHemi: cell of mask hemisphere labels (e.g. {'_left'; '_right'; ''}
%
% Out:
%   cAllMasks: 2-dimensional cell array of mask labels, with every combination of area and
%   hemisphere. Each column corresponds to a value in cHemi, and each
%   columnn corresponds to an area.

cMasks = reshape(cMasks, [], 1);
cHemi = reshape(cHemi, [], 1);
cAllMasks = {};

nHemi = numel(cHemi);
nMask = numel(cMasks);
for kH = 1:nHemi
    strHemi = cHemi{kH};
    for kM = 1:nMask
        strMask = cMasks{kM};
        cTemp{kM, 1} = [strMask, strHemi];
    end
    cAllMasks = horzcat(cAllMasks, cTemp);
end