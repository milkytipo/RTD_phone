function [pvtCalculator] = rinexnavi_data(recv_time,ephAll,satClkCorr,queue, pvtCalculator,logName)
satsys='C';
epoch_year = recv_time.year;
epoch_month = recv_time.month;
epoch_day = recv_time.day;
epoch_hour = recv_time.hour;
epoch_min = recv_time.min;
epoch_sec = round(recv_time.sec);
sv_bias = satClkCorr;
sv_drift = 0;
sv_rate = 0;
logNameIono = strcat(logName, 'Iono');
        
fid_1=fopen(logName,'at');
fid_2=fopen(logNameIono,'at');

for i=1:length(queue)
    if pvtCalculator.logOutput.BDSephUpdate(queue(i)) == 1
        IODE=ephAll(queue(i)).eph.IODE;
        Crs=ephAll(queue(i)).eph.Crs;
        Delta_n=ephAll(queue(i)).eph.deltan;
        M0=ephAll(queue(i)).eph.M0;
        Cuc=ephAll(queue(i)).eph.Cuc;
        e=ephAll(queue(i)).eph.e;
        Cus=ephAll(queue(i)).eph.Cus;
        sqrtA=ephAll(queue(i)).eph.sqrtA;
        toe=ephAll(queue(i)).eph.toe;
        Cic=ephAll(queue(i)).eph.Cic;
        omega0=ephAll(queue(i)).eph.omega0;
        Cis=ephAll(queue(i)).eph.Cis;
        i0=ephAll(queue(i)).eph.i0;
        Crc=ephAll(queue(i)).eph.Crc;
        omega=ephAll(queue(i)).eph.omega;
        omega_dot=ephAll(queue(i)).eph.omegaDot;
        IDOT=ephAll(queue(i)).eph.iDot;
        BDweek=ephAll(queue(i)).eph.weekNumber;
        spare=0;
        %%       
        fprintf(fid_1,'%1s%2.2d %4d %2.2d %2.2d %2.2d %2.2d %2.2d%19.12E%19.12E%19.12E\n',...
            satsys,queue(i),epoch_year,epoch_month,epoch_day,epoch_hour,epoch_min,epoch_sec,sv_bias(queue(i)),sv_drift,sv_rate);
        fprintf(fid_1,'    %19.12E%19.12E%19.12E%19.12E\n',IODE,Crs,Delta_n,M0);
        fprintf(fid_1,'    %19.12E%19.12E%19.12E%19.12E\n',Cuc,e,Cus,sqrtA);
        fprintf(fid_1,'    %19.12E%19.12E%19.12E%19.12E\n',toe,Cic,omega0,Cis);
        fprintf(fid_1,'    %19.12E%19.12E%19.12E%19.12E\n',i0,Crc,omega,omega_dot);
        fprintf(fid_1,'    %19.12E%19.12E%19.12E%19.12E\n',IDOT,spare,BDweek,spare);

        Alpha0=ephAll(queue(i)).eph.Alpha0;
        Alpha1=ephAll(queue(i)).eph.Alpha1;
        Alpha2=ephAll(queue(i)).eph.Alpha2;
        Alpha3=ephAll(queue(i)).eph.Alpha3;
        Beta0=ephAll(queue(i)).eph.Beta0;
        Beta1=ephAll(queue(i)).eph.Beta1;
        Beta2=ephAll(queue(i)).eph.Beta2;
        Beta3=ephAll(queue(i)).eph.Beta3;
        fprintf(fid_2,'>%4d %2.2d %2.2d %2.2d %2.2d %2.2d %2.2d\n',...
            epoch_year,epoch_month,epoch_day,epoch_hour,epoch_min,epoch_sec,length(queue));
        fprintf(fid_2,'%1s%2.2d %19.12E%19.12E%19.12E%19.12E%19.12E%19.12E%19.12E%19.12E\n',satsys,queue(i),Alpha0,Alpha1,Alpha2,Alpha3,Beta0,Beta1,Beta2,Beta3);
        pvtCalculator.logOutput.BDSephUpdate(queue(i)) = 0;
    end
end
fclose(fid_1);
fclose(fid_2);




