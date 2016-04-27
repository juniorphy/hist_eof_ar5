DIR=`pwd`

echo $DIR


#for MODEL in bccr_bcm2_0 cccma_cgcm3_1 cccma_cgcm3_1_t63 cnrm_cm3 csiro_mk3_0 csiro_mk3_5 gfdl_cm2_0 gfdl_cm2_1 giss_aom giss_model_e_h giss_model_e_r iap_fgoals1_0_g ingv_echam4 inmcm3_0 ipsl_cm4 miroc3_2_hires miroc3_2_medres miub_echo_g mpi_echam5 mri_cgcm2_3_2a ncar_ccsm3_0 ncar_pcm1 ukmo_hadcm3 ukmo_hadgem1; do 
for MODEL in `ls -1` ; do
cp ${DIR}/temporary.ersst.glb.70.99.nc $MODEL/

cd $MODEL/
echo MODEL $MODEL 
fin=`ls -1 tos_O*20??12.nc`
echo $fin
 
cdo setcalendar,standard -sellonlatbox,-90,20,-60,60 -seldate,1970-1-1,1999-12-31 -remapbil,"temporary.ersst.glb.70.99.nc" $fin "temporary.${fin}"

cat << EOF > gera_txt.jnl 
use "temporary.${fin}"
set var/bad=-999. tos
list/clobber/form=(300f10.2)/file="${DIR}/tos.mensal.$MODEL.1970.1999.txt" tos

EOF
ferret -script gera_txt.jnl



rm -f temporary.${fin}

cd ${DIR}

done
