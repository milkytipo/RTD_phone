*****************************************************
*** The LAMBDA-method: Matlab implementation V2.1 ***
*****************************************************

Use and Liability
-----------------

Use of the accompanying LAMBDA software is allowed, but no liability for the
use of the software will be accepted by the authors or their employer, the
Delft University of Technology.

Giving proper credits to the authors is the only condition posed upon the use
of the LAMBDA software. We ask you to refrain from passing the software to
third parties; instead you are asked to pass our (E-Mail) address to them, so
we can send the software upon their request. The reason is, that in this way
we have a complete overview of the users of the software, enabling us to keep
everyone informed of further developments.


Implementation
--------------

The implementation is described in LGR report No 12: `The LAMBDA method for
integer ambiguity estimation: implementation aspects'.  Instead of aiming for
utmost efficiency, our goal has been to make an implementation that is clear
and that has a one-to-one correspondence to the report.

For the accessing scheme of the matrices, we use the standard Matlab
2-dimensional array, even in the case where the matrix is symmetric or
triangular.

We are sure that still some efficiency can be gained, but for educational
reasons, as well for reasons of easy software maintenance we refrained from
that.


Testing and Updates
-------------------

We welcome any suggestion for improvement of the code, the in-source
documentation and the description in the report.  We also would like to
encourage you to communicate to us about results obtained with the LAMBDA
method, and comparisons made with other methods.  We would also be much
obliged if you inform us in case you decide to use the method commercially. As
said before, there are no restrictions on that, other than properly
acknowledging the designers of the method and their employer.

At this moment, several implementations in other computer languages (C, C++)
have been derived from the original Fortran version; none of them has been
made public yet however. If you are planning to make a version in an other
language, and would like to make it public, we would like you to contact us,
in order to coordinate the efforts.  Updated information about the LAMBDA
method will be available at http://www.geo.tudelft.nl/mgp/lambda/


System requirements:
--------------------

The routines were written and tested on a PC, running Windows 95, with Matlab
version 5.1. Later on, the routines were also tested using Matlab 5.2 on a PC,
running Linux (RedHat 5.2, kernel 2.0.36) as well as on a HP9000, running the
HPUX operating system (version B.10.20). Although not tested, it is believed
that the routines will run on any system on which Matlab is installed. As far
as known, none of the newer additions to Matlab were used, so it should work
on older versions as well. The included demonstration requires graphical
capabilities, so a windowing-system (either X11 or MS) is necessary for using
the demonstration.


Installation:
-------------

The software is provided as either a "zip-file", or a compressed unix
"tar-file". Extract all files, using your favourite software, to any directory
you wish. Make sure the directory is in the Matlab path. If necessary, the
directory can be added to the Matlab path with the following commands,
depending on your operating system:

 	Unix:	      path (path,'/yourhome/yourdirectory');
	VMS:	      path (path,'YOURDISK:[yourhome.yourdirectory]');
	DOS/Windows:  path (path,'yourhome\yourdirectory');
	Mac:	      path (path,'Yourdisk:yourdirectory:');

It might be a good idea to place such a statement in your startup.m file, to
avoid the necessity of issuing this command every time you wish to use the
routines. See your local installation of Matlab for instructions of how to do
this.


Distibuted files:
-----------------

amb18.m       Example, based on a kinematic survey
chistart.m    M-file to compute the size for the search ellipsoid
Contents.m    M-file, table of contents for Matlab help system
decorrel.m    M-file to decorrelate the ambiguities
geofree.mat   Example, 2-dimensional, can be used in demonstration
lambda.ps     Documentation, in PostScript format
lambda.pdf    Documention in portable document format
lambda1.m     M-file, main routine, complete version, with options
lambda2.m     M-file, main routine, straigthforward solution, no options
large.mat     Example, 12-dimensional, can NOT be used in demonstration
ldemo.m       M-file, demonstration
ldldecom.m    M-file, LtDL-decompostion
lsearch.m     M-file, ambiguity search
readme.txt    This file
sixdim.mat    Example, 6-dimensional, can be used in demonstration
small.mat     Example, 3-dimensional, can be used in demonstration
writemat.m    M-file, write matrices, only used in demonstration


Revision history:
-----------------
27-APR-2000: First official release of the MATLAB code, named V2.0
06-MAR-2001: Update, setting the size of the search-ellipsoid
             Effected files are "chistart.m", as well as the manual
             This version was named V2.1

Selected Literature on the LAMBDA method
----------------------------------------

Teunissen, P.J.G. (1993)  
  Least-squares estimation of the integer GPS ambiguities.
  Invited lecture, Section IV Theory and Methodology, IAG General Meeting, 
  Beijing, China, August,
  also in Delft Geodetic Computing Centre LGR series, No. 6, 16 pp.

Jonge de, P.J., and C.C.J.M. Tiberius (1996)    
  The LAMBDA method for integer ambiguity estimation: implementation 
  aspects. Delft Geodetic Computing Centre LGR series, No. 12.
  Available at "ftp://ftp.geo.tudelft.nl/pub/dejonge/papers/" as
  PostScript version: lgr12.ps

Teunissen, P.J.G. (1995)  
  The least-squares ambiguity decorrelation adjustment: a method for fast 
  GPS integer ambiguity estimation.
  Journal of Geodesy, Vol. 70, No. 1-2,
  pp. 65-82.

Teunissen, P.J.G. and Kleusberg, A (1998)  
  GPS for Geodesy, second enlarged edition, Springer Verlag
  See especially chapter 8, GPS carrier phase ambiguity fixing concepts.  

More literature can be found on our website, 
http://www.geo.tudelft.nl/mgp, look for "publications"

------------------------------------------------------------------------
Peter Joosten                                   Phone..: (31)15-2782713
Delft University of Technology                  Fax....: (31)15-2783711
Faculty of Civil Engineering and Geosciences
Thijsseweg 11
2629 JA Delft                     
The Netherlands                       Email..: P.Joosten@geo.tudelft.nl

"One mile of road or railway brings you nowhere,
                              one mile of runway brings you everywhere"
------------------------------------------------------------------------
