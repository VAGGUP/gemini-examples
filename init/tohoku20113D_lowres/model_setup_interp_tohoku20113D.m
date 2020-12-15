%A MEDIUM RES TOHOKU
dtheta=7.5;
dphi=12;
lp=96;
lq=284;
lphi=96;
altmin=80e3;
glat=42.45;
glon=143.4;
gridflag=1;
flagsource=1;


%RUN THE GRID GENERATION CODE
if (~exist('xg'))
  xg= gemini3d.grid.tilted_dipole3d(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%ALTERNATIVELY WE MAY WANT TO READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
p.file_format='raw';
p.eq_dir=[gemini_root,'/../simulations/tohoku20113D_eq/'];
p.simdir=[gemini_root,'/../simulations/input/tohoku20113D_lowres/'];
[nsi,vs1i,Tsi]= gemini3d.model.eq2dist(p,xg);
