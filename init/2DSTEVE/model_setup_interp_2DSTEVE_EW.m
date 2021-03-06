%LOWRES 2D EXAMPLE FOR TESTING
xdist=200e3;    %eastward distance
ydist=600e3;    %northward distance
lxp=80;
lyp=1;
glat=67.11;
glon=212.95;
gridflag=0;
I=90;


%RUN THE GRID GENERATION CODE
if (~exist('xg'))
  xg= gemini3d.grid.cart3d(xdist,lxp,ydist,lyp,I,glat,glon);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%ALTERNATIVELY WE MAY WANT TO READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
eqdir='../../../simulations/2Dtest_eq/';
simID='2DSTEVE';
[nsi,vs1i,Tsi,xgin,ns,vs1,Ts]= gemini3d.model.eq2dist(eqdir,simID,xg,file_format);
