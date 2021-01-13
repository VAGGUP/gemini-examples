%A MEDIUM RES TOHOKU
dtheta=7.5;
dphi=12;
lp=576;
lq=580;
lphi=576;
altmin=80e3;
glat=42.45;
glon=143.4;
gridflag=1;
flagsource=1;



%RUN THE GRID GENERATION CODE
if ~exist('xg', 'var')
    xg= gemini3d.grid.makegrid_tilteddipole_nonuniform_oneside_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%WRITE OUT THE GRID then flush memory
outdir=['~/zettergmdata/simulations/input/',simid,'/'];
gemini3d.write.grid(xg,outdir);    %just put it in pwd for now
x1i=xg.x1(3:end-2);
x2i=xg.x2(3:end-2);
x3i=xg.x3(3:end-2);
clear xg;


%IDENTIFICATION FOR THE NEW SIMULATION THAT IS TO BE DONE
simid='tohoku20113D_highres_restart'


%ALTERNATIVELY WE MAY WANT TO READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
fprintf('Reading in source file...\n');
ID='~/zettergmdata/simulations/tohoku20113D_highres_var/'


%READ IN THE SIMULATION INFORMATION
cfg = gemini3d.read.config(ID);
xgin=gemini3d.read.grid(ID);
direc=ID;
x1=xgin.x1(3:end-2);
x2=xgin.x2(3:end-2);
x3=xgin.x3(3:end-2);
clear xgin;


%LOAD THE FRAME
dat = gemini3d.read.frame(direc, "time", cfg.times(end));
lsp=size(ns,4);

%DO THE INTERPOLATION
if (lx3~=1)
  fprintf('Starting interp3''s...\n');
%  [X2,X1,X3]=meshgrid(xgin.x2(3:end-2),xgin.x1(3:end-2),xgin.x3(3:end-2));
%  [X2i,X1i,X3i]=meshgrid(xg.x2(3:end-2),xg.x1(3:end-2),xg.x3(3:end-2));
  [X2,X1,X3]=meshgrid(x2,x1,x3);
  [X2i,X1i,X3i]=meshgrid(x2i,x1i,x3i);
  for isp=1:lsp
    tmpvar=interp3(X2,X1,X3,ns(:,:,:,isp),X2i,X1i,X3i);
    inds=find(isnan(tmpvar));
    tmpvar(inds)=1e0;
    nsi(:,:,:,isp)=tmpvar;
    tmpvar=interp3(X2,X1,X3,vs1(:,:,:,isp),X2i,X1i,X3i);
    tmpvar(inds)=0e0;
    vs1i(:,:,:,isp)=tmpvar;
    tmpvar=interp3(X2,X1,X3,Ts(:,:,:,isp),X2i,X1i,X3i);
    tmpvar(inds)=100e0;
    Tsi(:,:,:,isp)=tmpvar;
  end
else
  fprintf('Starting interp2''s...\n');
  [X2,X1]=meshgrid(xgin.x2(3:end-2),xgin.x1(3:end-2));
  [X2i,X1i]=meshgrid(xg.x2(3:end-2),xg.x1(3:end-2));
  for isp=1:lsp
    tmpvar=interp2(X2,X1,squeeze(ns(:,:,:,isp)),X2i,X1i);
    inds=find(isnan(tmpvar));
    tmpvar(inds)=1e0;
    nsi(:,:,:,isp)=reshape(tmpvar,[lx1,lx2,1]);
    tmpvar=interp2(X2,X1,squeeze(vs1(:,:,:,isp)),X2i,X1i);
    tmpvar(inds)=0e0;
    vs1i(:,:,:,isp)=reshape(tmpvar,[lx1,lx2,1]);
    tmpvar=interp2(X2,X1,squeeze(Ts(:,:,:,isp)),X2i,X1i);
    tmpvar(inds)=100e0;
    Tsi(:,:,:,isp)=reshape(tmpvar,[lx1,lx2,1]);
  end
end


%WRITE OUT THE GRID
gemini3d.write.state(outdir, cfg.times(end),nsi,vs1i,Tsi)
