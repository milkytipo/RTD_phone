function [pos_xyz, pos_llh, pos_vel] = get_user_pos(pvtCalculator)
% This function is to get the current user position from the struct
% pvtCalculator. Since there exist the situations like 1)the current
% position is invalide; 2) there is no PVT sulution output but according to
% the kalman filter output, the predicted position is sitll deemed usable;
% 3) the kalman filter predicted output is invalid. So we need to give the
% correct judgement and current output.
pos_xyz = [];
pos_llh = [];
pos_vel = [];
if pvtCalculator.positionValid == 1
    pos_xyz = pvtCalculator.positionXYZ;
    pos_llh = pvtCalculator.positionLLH;
    pos_vel = pvtCalculator.positionVelocity;
end