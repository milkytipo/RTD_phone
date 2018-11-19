/*

 em_mvgm : Expectation-Maximization algorithm for Multivariate Gaussian Mixtures

 Usage  
 -------

 [logl , M , S , P]  = em_mvgm(Z , M0 , S0 , P0 , [nbite]);


 Inputs
 -------

 Z             Measurements (m x K x [n1] x ... x [nl])
 M0            Initial mean vector. M0 can be (m x 1 x p x [v1] x ... x [vr])
 S0            Initial covariance matrix. S0 can be (m x m x p x [v1] x ... x [vr])
 P0            Initial mixture probablities (1 x 1 x p) : P0 can be  (1 x 1 x d x [v1] x ... x [vr])
 nbite         Number of iteration (defaut = 10)


 Ouputs
 -------

 logl          Final loglikelihood (n1 x ... x nl x v1 x ... x vr)
 M             Estimated mean vector (m x 1 x p x n1 x ... x nl v1 x ... x vr)
 S             Estimated covariance vector (m x m x p x n1 x ... x nl v1 x ... x vr)
 P             Estimated initial probabilities (1 x 1 x p x n1 x ... x nl v1 x ... x vr)


To compile
----------

mex em_mvgm.c

or

mex -f mexopts_intel10.bat em_mvgm.c


Example 1
----------


   d                                   = 2;
   m                                   = 2;
   L                                   = 1;
   R                                   = 1;
   K                                   = 10000;
   nbite                               = 100;

   P                                   = cat(3 , [0.4] , [0.6]);
   M                                   = cat(3 , [-1 ; -1] , [1 ; 1]);
   S                                   = cat(3 , [1 0.3 ; 0.3 0.8] , [0.7 0.6; 0.6 1]);

   [Z ,  X]                            = sample_mvgm(K , M , S , P);

   P0                                  = rand(1 , 1 , d , R);
   sumP                                = sum(P0 , 3);
   P0                                  = P0./sumP(: , : , ones(d , 1) , :);
   
   M0                                  = randn(m , 1 , d , R);
   S0                                  = repmat(cat(3 , [2 0 ; 0 2] , [3 0; 0 2]) , [1 , 1 , 1, R]);


   [logl , Mest , Sest , Pest]         = em_mvgm(Z , M0 , S0 , P0 , nbite);
   [x , y]                             = ndellipse(M , S);
   [xest , yest]                       = ndellipse(Mest , Sest);

   L                                   = densgauss(Z , Mest , Sest , Pest);
 
   [val , Xest]                        = max(L);

   ind1                                = (Xest == 1);
   ind2                                = (Xest == 2);

   reshape(sum(X(: , : , ones(1 , R))~=Xest , 2)/K , 1 , R)

   figure(1) , plot(Z(1 , ind1) , Z(2 , ind1) , 'k+' , Z(1 , ind2) , Z(2 , ind2) , 'g+' , x , y , 'b' , reshape(xest , 50 , m*R)  , reshape(yest , 50 , m*R) ,'r', 'linewidth' , 2);


   [Znew ,  Xnew]                      = sample_mvgm(K , M , S , P);

   Lnew                                = densgauss(Znew , Mest , Sest , Pest);


   [val , Xnewest]                     = max(Lnew);

   ind1                                = (Xnewest == 1);
   ind2                                = (Xnewest == 2);

   sum(Xnew~=Xnewest)/K

   figure(2), plot(Znew(1 , ind1) , Znew(2 , ind1) , 'k+' , Znew(1 , ind2) , Znew(2 , ind2) , 'g+' , x , y , 'b' , xest  , yest ,'r', 'linewidth' , 2);


   Author : Sastien PARIS  ?(sebastien.paris@lsis.org)
   --------

*/

#include <math.h>
#include "mex.h"

#define NUMERICS_FLOAT_MIN 1.0E-37
#define M_PI 3.14159265358979323846
#ifndef max
    #define max(a,b) (a >= b ? a : b)
    #define min(a,b) (a <= b ? a : b)
#endif

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/

double gauss(double *, double * , int , int);
void lubksb(double *, int , int *, double *);
int ludcmp(double *, int , int *, double * , double *);
double inv(double * , double * , double * , double * , int * , int );
void em_mvgm(double * , double * , double * , double * , int  ,  double * , double * , double * , double *  , int , int , int , int , int , double * , double * , double * , double * , double * , double * , double * , double * , double * , double * , int * , double * , double * , double * , double *);

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/
void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray *prhs[] )
{	
	double *Z , *M0 , *S0 , *P0;	
	double *logl , *M , *S , *P;
	double *dens , *Ptemp  , *Mtemp , *Stemp;
	int  *indx;
	double *vect , *vv , *invS  , *temp_S , *temp_invS , *det_S , *res , *resZ , *sumP , *invP;
	const int *dimsZ , *dimsM0 , *dimsS0 , *dimsP0;
	int *dimslogl  , *dimsM , *dimsS , *dimsP;
	int numdimsZ  , numdimsM0 , numdimsS0 , numdimsP0;
	int numdimslogl , numdimsM , numdimsS , numdimsP;
	int nbite;
	int i , d2 , m2;
	int K , m  , d , L = 1 , R = 1;
	
	/*---------------------------------------------------------------*/
	/*---------------------- PARSE INPUT ----------------------------*/	
	/*---------------------------------------------------------------*/
	
	if( (nrhs < 4) )
	{	
		mexErrMsgTxt("At least 4 inputs are required");	
	}
		
	Z          = mxGetPr(prhs[0]);	
    numdimsZ   = mxGetNumberOfDimensions(prhs[0]);   
	dimsZ      = mxGetDimensions(prhs[0]);	
	K          = dimsZ[1];
	
	for(i = 2 ; i < numdimsZ ; i++)		
	{		
		L     *= dimsZ[i];				
	}
		
	M0         = mxGetPr(prhs[1]);   
    numdimsM0  = mxGetNumberOfDimensions(prhs[1]);   
	dimsM0     = mxGetDimensions(prhs[1]);	
	if (  (dimsM0[1] != 1)  )
	{		
		mexErrMsgTxt("M0 must be (m x 1 x  d x v1 x ... x vr)");			 		
	}
	
	m          = dimsM0[0];
	m2         = m*m;
	
	S0         = mxGetPr(prhs[2]);  
    numdimsS0  = mxGetNumberOfDimensions(prhs[2]);  
	dimsS0     = mxGetDimensions(prhs[2]);	
	if (  (dimsS0[1] != m)  )
	{		
		mexErrMsgTxt("S0 must be (m x m x  d x v1 x ... x vr)");			 		
	}
		
	P0        = mxGetPr(prhs[3]);   
    numdimsP0 = mxGetNumberOfDimensions(prhs[3]);   
	dimsP0     = mxGetDimensions(prhs[3]);	
	if (  dimsP0[0] != 1 && dimsP0[1] != 1 )
	{		
		mexErrMsgTxt("P must be (1 x 1 x d x v1 x ... x vr ) ");			 		
	}
	
	d          = dimsP0[2];	
	d2         = d*d;	
	for(i = 3 ; i < numdimsP0 ; i++)	
	{	
		R     *= dimsP0[i];
	}
	
	if(nrhs < 5)		
	{
		nbite      = 10;
	}	
	else
	{		
		nbite      = (int) mxGetScalar(prhs[4]);		
	}
		
	/*---------------------------------------------------------------*/
	/*---------------------- PARSE OUTPUT ---------------------------*/	
	/*---------------------------------------------------------------*/
	
	numdimslogl    = max(numdimsZ - 2 + numdimsP0 - 3 , 2);	
	dimslogl       = (int *)mxMalloc(numdimslogl*sizeof(int));	
	dimslogl[0]    = 1;	
	dimslogl[1]    = 1;
		
	numdimsM       = 3 + max(numdimsZ - 2 , 0) + max(numdimsP0 - 3 , 0);	
	dimsM          = (int *)mxMalloc(numdimsM*sizeof(int));	
	dimsM[0]       = m;
	dimsM[1]       = 1;
	dimsM[2]       = d;
		
	numdimsS       = 3 + max(numdimsZ - 2 , 0) + max(numdimsP0 - 3 , 0);
	dimsS          = (int *)mxMalloc(numdimsS*sizeof(int));
	dimsS[0]       = m;
	dimsS[1]       = m;
	dimsS[2]       = d;
	
	
	numdimsP       = 3 + max(numdimsZ - 2 , 0) + max(numdimsP0 - 3 , 0);
	dimsP          = (int *)mxMalloc(numdimsP*sizeof(int));
	dimsP[0]       = 1;
	dimsP[1]       = 1;
	dimsP[2]       = d;
	
	for(i = 2 ; i < numdimsZ ; i++)
	{
		dimslogl[i - 2]   = dimsZ[i];
		dimsM[i + 1]      = dimsZ[i];
		dimsS[i + 1]      = dimsZ[i];
		dimsP[i + 1]      = dimsZ[i];
	}
	
	for(i = 3 ; i < numdimsP0 ; i++)	
	{	
		dimslogl[i  - 3 + (numdimsZ - 2)] = dimsP0[i];	
		dimsM[i  + (numdimsZ - 2)]        = dimsP0[i];	
		dimsS[i  + (numdimsZ - 2)]        = dimsP0[i];		
		dimsP[i  + (numdimsZ - 2)]        = dimsP0[i];			
	}
	
	plhs[0]        = mxCreateNumericArray(numdimslogl , dimslogl , mxDOUBLE_CLASS, mxREAL);
	logl           = mxGetPr(plhs[0]);
		
	plhs[1]        = mxCreateNumericArray(numdimsM , dimsM , mxDOUBLE_CLASS, mxREAL);    
	M              = mxGetPr(plhs[1]);
		
	plhs[2]        = mxCreateNumericArray(numdimsS , dimsS , mxDOUBLE_CLASS, mxREAL);   
	S              = mxGetPr(plhs[2]);
		
	plhs[3]        = mxCreateNumericArray(numdimsP , dimsP , mxDOUBLE_CLASS, mxREAL);    
	P              = mxGetPr(plhs[3]);
		
	dens           = (double *)malloc(d*K*sizeof(double));
	Mtemp          = (double *)malloc(m*d*sizeof(double));
	Stemp          = (double *)malloc(m2*d*sizeof(double));
	Ptemp          = (double *)malloc(d*sizeof(double));
	
	vect           = (double *)malloc(m*sizeof(double));
	vv             = (double *)malloc(m*sizeof(double));
	temp_S         = (double *)malloc(m2*sizeof(double));
	temp_invS      = (double *)malloc(m2*sizeof(double));
	det_S          = (double *)malloc(d*sizeof(double));
	invS           = (double *)malloc((m2*d)*sizeof(double));
	res            = (double *)malloc(m*sizeof(double));
	resZ           = (double *)malloc(m*d*K*sizeof(double));
	sumP           = (double *)malloc(d*sizeof(double));
	invP           = (double *)malloc(d*sizeof(double));
	indx           = (int *)malloc(m*sizeof(int));

	/*---------------------------------------------------------------*/
	/*------------------------ MAIN CALL ----------------------------*/
	/*---------------------------------------------------------------*/
	
	em_mvgm(Z ,  M0  , S0 , P0 , nbite , logl , M , S , P , m , d , K , L , R , dens  , Mtemp , Stemp , Ptemp , invS , temp_S , temp_invS , det_S , vect , vv , indx , res , resZ , sumP , invP);
		
	/*---------------------------------------------------------------*/
	/*------------------------ FREE MEMORY --------------------------*/
	/*---------------------------------------------------------------*/
	
	
    mxFree(dimslogl);
	mxFree(dimsM);
	mxFree(dimsS);
    mxFree(dimsP);

	free(dens);
	free(Mtemp);
	free(Stemp);
	free(Ptemp);
	free(vect);
	free(vv);
	free(temp_S);
	free(temp_invS);
	free(det_S);
	free(invS);
	free(indx);
	free(res);
	free(resZ);
	free(sumP);
	free(invP);	
}

/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*/

void em_mvgm(double *Z , double *M0 , double *S0 , double *P0 , int nbite , double *logl , double *M , double *S , double *P  , int m , int d , int K , int L , int R , double *dens , double *Mtemp , double *Stemp , double *Ptemp , double *invS , double *temp_S , double *temp_invS , double *det_S , double *vect , double *vv , int *indx , double *res , double *resZ , double *sumP , double *invP)			 
{
	int i , j , l , k  , h , t , r , d2 = d*d , m2 = m*m, rd , rd2 , md = m*d , mK = m*K , rmd , m2d = m2*d , rm2d, rL;
	int kd , lmK , index , index1 , rLd , rLd2 , rLmd , Ld = L*d , Lmd = Ld*m;
	int ld , ld2 , lmd , rLm2d , lm2d , Lm2d = L*m2d , im2 , km , jm , jmK , imK ;
	double cte = 1.0/pow(2*M_PI , m/2.0);
    register double sum , invsum , temp;

	for(r = 0 ; r < R ; r++)	
	{
        rd    = r*d;
        rd2   = r*d2;
		rmd   = r*md;
        rm2d  = r*m2d;
		rL    = r*L;
		rLd   = r*Ld;
		rLd2  = rLd*d;
		rLmd  = r*Lmd;
		rLm2d = r*Lm2d;
		
		for (l = 0 ; l < L ; l++)
		{
			lmK  = l*mK;
			ld   = l*d  + rLd;
			ld2  = l*d2 + rLd2;			
			lmd  = l*md + rLmd;
			lm2d = l*m2d + rLm2d;
			/* Copy Initial parameters */
			for(i = 0 ; i < md ; i++)
			{
				Mtemp [i] = M0[i + rmd]; 
			}
			for(i = 0 ; i < m2d ; i++)
			{
				Stemp [i] = S0[i + rm2d]; 
			}
			for(i = 0 ; i < d ; i++)
			{
				Ptemp [i] = P0[i + rd]; 
			}
			for(t = 0 ; t < nbite ; t++)
			{
				/* invS = inv(S); */
				
				for (i = 0 ; i < d ; i++)
				{
					im2   = i*m2;
					for(j = 0 ; j < m2 ; j++)
					{
						temp_S[j] = Stemp[j + im2];
					}
					det_S[i]  = inv(temp_S , temp_invS , vect , vv , indx , m);
					for(j = 0 ; j < m2 ; j++)
					{
						invS[j + im2] = temp_invS[j];
					}
					det_S[i] = (cte*sqrt(fabs(det_S[i])));
				}
				/* dens = cte*exp(-0.5res'*invS*res) */

				logl[l + rL] = 0.0;
				for(j = 0 ; j < d ; j++)
				{
					sumP[j]  = 0.0;
				}
				for (k = 0 ; k < K ; k++)
				{
					km    = k*m + lmK;
					kd    = k*d;
					sum   = 0.0;
					for (j = 0 ; j < d ; j++)
					{
						jm            = j*m;
						for(i = 0 ; i < m ; i++)
						{
							res[i] = (Z[i + km] - Mtemp[i + jm]);
						}
						temp          = Ptemp[j]*det_S[j]*exp(-0.5*gauss(res , invS , m , j*m2));
						dens[j + kd]  = temp;
						sum          += temp;
					}
					logl[l + rL]     += log(sum);
					invsum            = 1.0/(sum + NUMERICS_FLOAT_MIN);
					for(j = 0 ; j < d ; j++)
					{
						dens[j + kd] *= invsum;
						sumP[j]      += dens[j + kd];
					}
				}
				
				/* Estimation P */
				
				sum              = 0.0;
				for (j = 0 ; j < d ; j++)
				{
					sum         += sumP[j];
				}
				invsum = 1.0/sum;
				for (j = 0 ; j < d ; j++)
				{
					Ptemp[j] = sumP[j]*invsum;	
					invP[j]  = 1.0/(sumP[j] + NUMERICS_FLOAT_MIN);
				}
				/* Density normalization */
				for (k = 0 ; k < K ; k++)
				{
					kd    = k*d;
					for (j = 0 ; j < d ; j++)
					{
						dens[j + kd] *= invP[j];
					}
				}
				/* M parameters */
				for (j = 0 ; j < d ; j++)
				{
					jm            = j*m;
					for(i = 0 ; i < m ; i++)
					{
						sum       = 0.0;
						for (k = 0 ; k < K ; k++)
						{
							sum += Z[i + k*m + lmK]*dens[j + k*d];
						}
						Mtemp[i + jm] = sum;
					}
				}

				/* resZ(m x K x d) */
				for(j = 0 ; j < d ; j++)
				{
					jmK = j*mK;
					jm  = j*m;
					for(k = 0 ; k < K ; k++)
					{
						km     = k*m;
						index  = km + lmK;
						index1 = km + jmK;
						for(i = 0 ; i < m ; i++)
						{
							resZ[i + index1] = (Z[i + index] - Mtemp[i + jm]);
						}
					}
				}
				
				/* S parameters */				
				for(i = 0 ; i < d ; i++)
				{
					im2 = i*m2;
					imK = i*mK;
					for (j = 0 ; j < m ; j ++)
					{
						for (h = 0 ; h <= j ; h++)
						{
							sum = 0.0;
							for (k = 0 ; k < K ; k++)
							{
								km    = k*m + imK;
								kd    = k*d;
								sum  += resZ[j + km]*resZ[h + km]*dens[i + kd];
							}
							Stemp[j + h*m + im2] = sum;
						}		
					}
					for (j = 0 ; j < m - 1 ; j++)
					{
						jm     = j*m;
						for (h = j + 1 ; h < m ; h++)
						{
							Stemp[h*m + j + im2] = Stemp[h + jm + im2];			
						}
					}
				}
			}
			/* Output results */
			for(i = 0 ; i < md ; i++)
			{
				M[i + lmd] = Mtemp[i]; 
			}
			for(i = 0 ; i < m2d ; i++)
			{
				S[i + lm2d] = Stemp[i]; 
			}
			for(i = 0 ; i < d ; i++)
			{
				P[i + ld] = Ptemp[i]; 
			}
		}
	}
}
/*----------------------------------------------------------------------------------------------*/
double gauss(double *y, double *R , int d , int offset)
{
	int  i , j , id;
	register double temp;
	register double Q = 0.0;
	for (i = 0 ; i < d ; i++)
	{
		temp = 0.0;
		id   = i*d + offset;
		for(j = 0 ; j < d ; j++)
		{
			temp   += y[j]*R[j + id];
		}
		Q += temp*y[i];
	}
	return Q;
}
/*------------------------------------------------------------------*/
double inv(double *temp , double *invQ  , double *vect , double *vv , int *indx , int d)
{
	int i , j , jd;
	double dd , det = 1.0;
	
	if(ludcmp(temp , d , indx , &dd , vv ))
	{
		for(i = 0 ; i < d ; i++)
		{
			det *= temp[i + i*d];
		}
		for(j = 0; j < d; j++)
		{            
			for(i = 0; i < d; i++) 
			{
				vect[i] = 0.0;
			}
			jd      = j*d;
			vect[j] = 1.0;
			lubksb(temp , d , indx , vect);
			for(i = 0 ; i < d ; i++) 
			{
				invQ[jd + i] = vect[i];
			}
		}
	}
	return (1.0/det);
}
/*-------------------------------------------------------------------------------*/
void lubksb(double *m, int n, int *indx, double *b)
{
    int i, ii = -1, ip, j , nn = n*n, in;
    double sum;
    for(i = 0; i < n; i++)
	{
        ip        = *(indx + i);
        sum       = *(b + ip);
        *(b + ip) = *(b + i);
        if(ii > -1)
		{
            for(j = ii; j <= i - 1; j++)
			{
                sum -= m[i + j*n] * *(b + j);
            }
        } 
		else if(sum)
		{
            ii = i;
        }
        *(b + i) = sum;
    }
    
	for(i = n - 1; i >= 0; i--)
	{
        sum = *(b + i);
		in  = i*n;
        for(j = i + 1; j < n; j++)
		{
            sum -= m[i + j*n] * *(b + j);
        }
		*(b + i) = sum / m[i + in];
    }
}
/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*/

int ludcmp(double *m, int n, int *indx, double *d , double *vv)
{
    int i, imax, j, k , jn , kn , n1 = n - 1;
    double big, dum, sum , temp;
	
    d[0] = 1.0;
    for(i = 0; i < n; i++)
	{
        big = 0.0;
        for(j = 0; j < n; j++)
		{
            if((temp = fabs(m[i + j*n])) > big)
			{
                big = temp;
            }
		}
        if(big == 0.0)
		{
            return 0;
        }
		
        vv[i] = 1.0 / big;
    }
    for(j = 0; j < n; j++)
	{
		jn  = j*n;
		
        for(i = 0; i < j; i++)
			
		{
            sum = m[i + jn];
            for(k = 0 ; k < i; k++)
			{
                sum -= m[i + k*n ] * m[k + jn];
            }
            
			m[i + jn] = sum;
        }
        big = 0.0;
        for(i = j; i < n; i++)
		{
            sum = m[i + jn];
            for(k = 0; k < j; k++)
			{
				sum -= m[i + k*n] * m[k + jn];
			}
            
			m[i + jn] = sum;
            if((dum = vv[i] * fabs(sum)) >= big)
			{
                big  = dum;
                imax = i;
            }
        }
		if(j != imax)
		{
            for(k = 0; k < n; k++)
			{
				kn            = k*n;
                dum           = m[imax + kn];
                m[imax + kn]  = m[j + kn];
                m[j + kn]     = dum;
            }
			d[0]       = -d[0];
            vv[imax]   = vv[j];
        }
        indx[j] = imax;
        if(m[j + jn] == 0.0)
		{
			m[j + jn] = NUMERICS_FLOAT_MIN;
		}
		if(j != n1)
		{
            dum = 1.0 / (m[j + jn]);
            for(i = j + 1; i < n; i++)
			{
				m[i + jn] *= dum;
			}
        }
    }
    return 1;
};
/*-------------------------------------------------------------------------*/
