%RISR PERIODIC KHI RUN
xdist=300e3
ydist=216e3;
lxp=1440;    %Andres example with 1km transition width
lyp=1080;    %Andres examples with 1km transition

%xdist=xdist*2;    %this scales up to deal with the largers scales for a 5km transition
%ydist=ydist*2;    %5km transition, likely precludes study of inverse cascade...

glat=75.6975;
glon=360.0-94.8322;
gridflag=0;
I=90;


%RUN THE GRID GENERATION CODE
if ~exist('xg', 'var')
  xg= gemini3d.grid.makegrid_cart_3D_lowresx1(xdist,lxp,ydist,lyp,I,glat,glon);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%IDENTIFICATION FOR THE NEW SIMULATION THAT IS TO BE DONE
simid='KHI_Andres'


%ALTERNATIVELY WE MAY WANT TO READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
fprintf('Reading in source file...\n');
ID=[gemini_root,'/../simulations/KHI_Andres_eq/'];


%READ IN THE SIMULATION INFORMATION
cfg = gemini3d.read.config(ID);
xgin= gemini3d.read.grid(ID);

direc=ID;

%LOAD THE FRAME
dat = gemini3d.read.frame(direc, "time", cfg.times(end));
lsp=size(ns,4);


%DO THE INTERPOLATION
if (lx3~=1)
  fprintf('Starting interp3''s...\n');
  [X2,X1,X3]=meshgrid(xgin.x2(3:end-2),xgin.x1(3:end-2),xgin.x3(3:end-2));
  [X2i,X1i,X3i]=meshgrid(xg.x2(3:end-2),xg.x1(3:end-2),xg.x3(3:end-2));
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
outdir= fullfile(gemini_root, '../simulations/input/KHI_Andres/');
gemini3d.write.grid(xg, outdir);
gemini3d.write.state(outdir, dat.time,nsi,vs1i,Tsi)
