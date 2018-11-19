% LAMBDA toolbox
% Version V2.1 dd. 05-MAR-2001
% 
% Main routines:
%   lambda1   - Integer estimation, extended options
%   lambda2   - Integer estimation, basic options
%
% Demonstration:
%   ldemo     - Demonstration of the LAMBDA-method
%
% Additional routines:
%   chistart  - Compute initial size of search ellipsoid
%   decorrel  - Decorrelate a variance/covariance matrix, and
%               return the Z-matrix (transformation matrix)
%   ldldecom  - Find LtDL decomposition of a matrix
%   lsearch   - Perform the integer least squares search
%   writemat  - Write contents of matrix to file/screen
%
% Data-files:
%   amb18.mat   - Large example, based on a kinematic survey
%   geofree.mat - Example, based on the geomtry-free model
%   large.mat   - Large example (not suited for ldemo)
%   sixdim.mat  - 6-dimensional example (suited for ldemo)
%   small.mat   - Small example (var/covar matrix + ambiguities)

%
% 
% (c)2001 by: Department of Mathematical Geodesy and Positioning
%             Delft University of Technology
%             Thijsseweg 11, NL-2629 JA, The Netherlands
%             Email: mgp@geo.tudelft.nl
%             Phone: +31 (15) 278 3546, Telefax: +31 (15) 278 3711


