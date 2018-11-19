function [Seq, Seg_Len] = BlockFolding(Code_Seq, Seg_N, FoldFlag)
% Function: Splitting one period of local codes into Seg_N segments
%Input:
% Code_Seq         -sampled chip sequence of a CM period;
% Seg_N            -number of folded segments splitted in a period;
% FoldFlag         -Folding operation flag: 'Folded'->summing up the 
%                   splitted segments; 'nonFolded'->save the splitted
%                   sequences into a matrix, not summing up.
%Output:
% Seq              -splitted code sequences, a row-wise vector if 
%                   FoldFlag='Folded', a Seg_N-by-Seg_Len matrix if
%                   FoldFlag='nonFolded';
% Seg_Len          -the column length of Seq, a length of the folded
%                   subsequences.

% Initializing
Seg_Len = 0;
Seq = 0;
N = length(Code_Seq);

% Splitting an entire period into Seg_N segments
if ( mod(N,Seg_N)~=0 )
    
    disp('The length of SegmentData is not an integer!');
    return;
    
end

Segment_Len = N/Seg_N;      % the length of a subsegment

Segment_Seq = zeros(Seg_N, Segment_Len);   % create mems for subsegments


% Splitting a period into Seg_N segments as matrix Seg_N x Segment_Len
for i=1:Seg_N
    
    indx = 1+(i-1)*Segment_Len : i*Segment_Len;     
    Segment_Seq(i,:) = Code_Seq(indx); 
    
end

% summing up the splitted segments
if Seg_N==1
    
    % Seg_N==1 means no splitting
    Segment_Sum = Segment_Seq;
    
elseif Seg_N>1
    % folding the segments codes
    Segment_Sum = sum(Segment_Seq); 
end
    
% return folded codes or splitted codes according to FoldFlag
if strcmp(FoldFlag,'Folded')  
    Seq = Segment_Sum; 
elseif strcmp(FoldFlag,'nonFolded')
    Seq = Segment_Seq;
else
    error('Unrecognized FoldFlag');
end
 
Seg_Len = Segment_Len;

return;

s