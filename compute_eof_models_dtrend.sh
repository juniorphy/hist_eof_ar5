    #!/bin/bash
DIR=`pwd`

#for MODEL in bccr_bcm2_0 cccma_cgcm3_1 cccma_cgcm3_1_t63 cnrm_cm3 csiro_mk3_0 csiro_mk3_5 gfdl_cm2_0 gfdl_cm2_1 giss_aom giss_model_e_h giss_model_e_r iap_fgoals1_0_g ingv_echam4 inmcm3_0 ipsl_cm4 miroc3_2_hires miroc3_2_medres miub_echo_g mpi_echam5 mri_cgcm2_3_2a ncar_ccsm3_0 ncar_pcm1 ukmo_hadcm3 ukmo_hadgem1; do 

for DUMP in `ls -d */ ` ; do
 
MODEL=${DUMP:0:-1}

cp ${DIR}/grid*.trop.nc ${MODEL}

cd $MODEL
echo MODEL $MODEL 
fin=`ls -1 tos_Omon_*.nc`
echo $fin

cdo setcalendar,standard -seldate,1970-12-1,1999-12-31 -remapbil,grid.ersst.atlantico.trop.nc $fin "g.errsst.$fin"

#$CDO genbil,${GRID_TARGET} ${FILEIN} weights.nc
#$CDO remap,${GRID_TARGET},weights.nc ${FILEIN} ${FILEOUT}.T42.nc

mkdir dtred
cd dtred
cdo detrend ../g.errsst.$fin dtred.errsst.${fin}

cat << EOF > eof.jnl 

USE climatological_axes
CANCEL DATA climatological_axes
!use the length of the "climatological year" to define a daily axis

!DEFINE AXIS/T=0:365.25/EDGES/NPOINTS=365/T0=1-JAN-0001/UNITS=days/MODULO tdaily

set data dtred.errsst.$fin

! define the monthly climatology
LET tosclim = tos[GT=month_reg@mod]

! define daily anomaly 
LET anom = tos - tosclim[gt=tos@asn]

save/clobber/file=anom.$MODEL.70.99.nc anom

let stats = EOF_STAT(anom,0.8)

let space = EOF_SPACE(anom,0.8)

let tfunc = EOF_TFUNC(anom,0.8)

save/clobber/file=eof.$MODEL.stats.nc stats
!save/clobber/file=eof.$MODEL.space.nc space
save/clobber/file=eof.$MODEL.tfunc.nc tfunc

EOF

ferret -nojnl -gif -script eof.jnl


#  ---FIGURAS da EOF ANUAL------------------------------------------

cat << EOF > eof.fig.jnl
use eof.${MODEL}.stats.nc
let ss1=stats[i=1,j=2,d=1]
let ss2=stats[i=2,j=2,d=1]
let ss3=stats[i=3,j=2,d=1]
let ss4=stats[i=4,j=2,d=1]
define sym v1=\`ss1,p=-2\`
define sym v2=\`ss2,p=-2\`
define sym v3=\`ss3,p=-2\`
define sym v4=\`ss4,p=-2\`
set win/asp=0.7777
say (\$v1)

use anom.$MODEL.70.99.nc
use eof.${MODEL}.tfunc.nc

let q = ANOM[d=2]
let p = tfunc[d=3,i=1,gt=q@ASN]
go variance
!set viewport ul
fill/lev=(-inf)(-0.8,0.8,0.2)(inf)/pal=inv_white_centered_junior/title="EOF1 - (\$v1)%" correl
contour/lev=(-inf)(-0.8,0.8,0.1)(inf)/o correl ; go fland
frame/file=eof1.dtred.annual.${MODEL}.correl.gif

let q = ANOM[d=2]
let p = tfunc[d=3,i=2,gt=q@ASN]
go variance
!set viewport ur
fill/lev=(-inf)(-0.8,0.8,0.2)(inf)/pal=inv_white_centered_junior/title="EOF2 - (\$v2)%" correl
contour/lev=(-inf)(-0.8,0.8,0.1)(inf)/o correl ; go fland
frame/file=eof2.dtred.annual.${MODEL}.correl.gif

!inicio de comentario
!let q = ANOM[d=2]
!let p = tfunc[d=3,i=3,gt=q@ASN]
!go variance
!set viewport ll                                                                                                                 
!fill/lev=(-inf)(-0.8,0.8,0.1)(inf)/pal=inv_white_centered_junior/title="EOF3 - (\$v3)%" correl
!contour/lev=(-inf)(-0.8,0.8,0.1)(inf)/o correl ; go fland

!let q = ANOM[d=2]
!let p = tfunc[d=3,i=4,gt=q@ASN]
!go variance
!set viewport lr                                                                                                                 
!fill/lev=(-inf)(-0.8,0.8,0.1)(inf)/pal=inv_white_centered_junior/title="EOF4 - (\$v4)%" correl
!contour/lev=(-inf)(-0.8,0.8,0.1)(inf)/o correl ; go fland
!frame/file=eof.dtred.annual.${MODEL}.correl.gif


!cancel viewport
!use eof.${MODEL}.tfunc.nc


!set viewport ul
!plot/vlim=-3:3/title="PC1 - (\$v1)% " tfunc[i=1,d=3]
!list/form=(f10.5)/nohead/clobber/file=PC1.${MODEL}.txt tfunc[i=1,d=3]

!set viewport ur
!plot/vlim=-3:3/title="PC2 - (\$v2)%" tfunc[i=2,d=3]
!list/form=(f10.5)/nohead/clobber/file=PC2.${MODEL}.txt tfunc[i=2,d=3]
!set viewport ll                                                                                                                 
!plot/vlim=-3:3/title="PC3 - (\$v3)%" tfunc[i=3,d=3]
!list/form=(f10.5)/nohead/clobber/file=PC3.${MODEL}.txt tfunc[i=3,d=3]
!set viewport lr                                                                                                                 
!plot/vlim=-3:3/title="PC4 - (\$v4)%" tfunc[i=4,d=3]
!list/form=(f10.5)/nohead/clobber/file=PC4.${MODEL}.txt tfunc[i=4,d=3]
!frame/file=eof.dtred.${MODEL}.pc.gif

EOF

ferret -gif -script eof.fig.jnl

# processamento das EOF Sazonais...

cdo seasmean -selseas,1 -seldate,1970-12-01,1999-11-30 anom.$MODEL.70.99.nc $MODEL.DJF.70.99.nc
cdo seasmean -selseas,2 -seldate,1970-12-01,1999-11-30 anom.$MODEL.70.99.nc $MODEL.MAM.70.99.nc
cdo seasmean -selseas,3 -seldate,1970-12-01,1999-11-30 anom.$MODEL.70.99.nc $MODEL.JJA.70.99.nc
cdo seasmean -selseas,4 -seldate,1970-12-01,1999-11-30 anom.$MODEL.70.99.nc $MODEL.SON.70.99.nc

#skip(){
for TRI in DJF MAM JJA SON ; do

echo $TRI

cat << EOF > eof.${TRI}.jnl 
say aqui
set data ${MODEL}.${TRI}.70.99.nc
say aqui
let stats = EOF_STAT(anom,0.8)

let space = EOF_SPACE(anom,0.8)

let tfunc = EOF_TFUNC(anom,0.8)

save/clobber/file=eof.${TRI}.${MODEL}.stats.nc stats
!save/clobber/file=eof.${TRI}.${MODEL}.space.nc space
save/clobber/file=eof.${TRI}.${MODEL}.tfunc.nc tfunc

EOF

ferret -nojnl -gif -script eof.${TRI}.jnl

# figuras EOF sazonais

cat << EOF > eof.fig.${TRI}.jnl 
set win/asp=0.7777
use eof.${TRI}.${MODEL}.stats.nc
let ss1=stats[i=1,j=2,d=1]
let ss2=stats[i=2,j=2,d=1]
let ss3=stats[i=3,j=2,d=1]
let ss4=stats[i=4,j=2,d=1]
define sym v1=\`ss1,p=-2\`
define sym v2=\`ss2,p=-2\`
define sym v3=\`ss3,p=-2\`
define sym v4=\`ss4,p=-2\`

say (\$v1)

use ${MODEL}.${TRI}.70.99.nc
use eof.${TRI}.${MODEL}.tfunc.nc

say ${TRI}
   
let q = ANOM[d=2]
let p = tfunc[d=3,i=1,gt=q@ASN]
go variance    
!set viewport ul
fill/lev=(-inf)(-0.8,0.8,0.1)(inf)/pal=inv_white_centered_junior/title="EOF1 - Correl - (\$v1)%" correl
contour/o/lev=(-inf)(-0.8,0.8,0.1)(inf)/title="EOF1 - Correl - (\$v1)%" correl ; go fland
!let co = if correl le 10 then correl else 999.
!repeat/i=1:45 (repeat/j=1:25 ( list/nohead/append/file=${MODEL}.${TRI}.space1.txt co ))
frame/file=eof1.dtred.${TRI}.${MODEL}.correl.gif

let q = ANOM[d=2]
let p = tfunc[d=3,i=2,gt=q@ASN]
go variance
!set viewport ur
fill/lev=(-inf)(-0.8,0.8,0.1)(inf)/pal=inv_white_centered_junior/title="EOF2 - Correl - (\$v2)%" correl
contour/lev=(-inf)(-0.8,0.8,0.1)(inf)/title="EOF2 - Correl - (\$v2)%" correl ; go fland
!let co = if correl le 10 then correl else 999.
!repeat/i=1:45 (repeat/j=1:25 ( list/nohead/append/file=${MODEL}.${TRI}.space2.txt co ))
frame/file=eof2.dtred.${TRI}.${MODEL}.correl.gif

!let q = ANOM[d=2]
!let p = tfunc[d=3,i=3,gt=q@ASN]
!go variance
!set viewport ll                                     
!fill/lev=(-inf)(-0.8,0.8,0.1)(inf)/pal=inv_white_centered_junior/title="EOF3 - Correl - (\$v3)%" correl
!contour/lev=(-inf)(-0.8,0.8,0.1)(inf)/o correl ; go fland

!let q = ANOM[d=2]
!let p = tfunc[d=3,i=4,gt=q@ASN]
!go variance
!set viewport lr                                  
!fill/lev=(-inf)(-0.8,0.8,0.1)(inf)/pal=inv_white_centered_junior/title="EOF4 - Correl - (\$v4)%" correl
!contour/lev=(-inf)(-0.8,0.8,0.1)(inf)/o correl ; go fland
!frame/file=eof.dtred.${TRI}.${MODEL}.correl.gif

cancel viewport

use eof.${TRI}.${MODEL}.tfunc.nc

set viewport ul
plot/vlim=-3:3/title="PC1 - (\$v1)% " tfunc[i=1,d=3]
list/form=(f10.5)/nohead/clobber/file=PC1.${TRI}.${MODEL}.txt tfunc[i=1,d=3]

set viewport ur
plot/vlim=-3:3/title="PC2 - (\$v2)%" tfunc[i=2,d=3]
list/form=(f10.5)/nohead/clobber/file=PC2.${TRI}.${MODEL}.txt tfunc[i=2,d=3]

set viewport ll                                                
plot/vlim=-3:3/title="PC3 - (\$v3)%" tfunc[i=3,d=3]
list/form=(f10.5)/nohead/clobber/file=PC3.${TRI}.${MODEL}.txt tfunc[i=3,d=3]

set viewport lr
plot/vlim=-3:3/title="PC4 - (\$v4)%" tfunc[i=4,d=3]
list/form=(f10.5)/nohead/clobber/file=PC4.${TRI}.${MODEL}.txt tfunc[i=4,d=3]
frame/file=eof.dtred.${TRI}.${MODEL}.pc.gif

EOF

ferret -nojnl -gif -script eof.fig.${TRI}.jnl

done # TRI
#}

#zip ${MODEL}.zip *txt *gif
cd $DIR
#ls -lrth
#read
done  #modeld 
