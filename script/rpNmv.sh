#!/bin/bash
# This shell repeats p3dx_2dnav.launch for N times
function help()
{
  #echo "rpNmv.sh MCL_PKG N MPBEGIN MPEND RIBEGIN RIEND DEST [SUFFIX]"
  echo "rpNmv.sh MCL_PKG N MPBEGIN MPEND RIBEGIN RIEND [FLAG SUFFIX]"
  echo "MCL_PKG is the name of MCL algorithms, amcl, mixmcl, and mcmcl."
  echo "N is the number of repeating."
  echo "MPBEGIN and MPEND are max_particles parameters where increment is 1000."
  echo "RIBEGIN and RIEND are begin and end of resample_interval parameters where increment is 1."
  echo "FLAG e.g. dual_normalizer_ita:=1e-2"
  echo "SUFFIX of mixmcl and mcmcl is _ita1e-1 or _ita1e-2_gamma2 which comes along with FLAG."
  #echo "DEST is destination folder."
}

if [[ $# < 2 ]]; then
  echo "wrong argument number $#"
  help
  exit 1
fi
#count=1
#for i in $*
#do
#  echo "${count}:${i}"
#  count=$(($count+1))
#done
MCLPKG=$1
RUNS=$2
MPBEGIN=$3
MPEND=$4
RIBEGIN=$5
RIEND=$6
#DEST_DIR=$7
DEST_DIR="/media/jolly/storejet/ex3/topleft/"
#DEST_DIR="/media/jolly/storejet/ex3/whole/"
#DEST_DIR="/home/jolly/ex3/topleft/"
#if [[ ! -d ${DEST_DIR} ]]; then
#  echo "${DEST_DIR} doesn't exist" && exit 1
#fi
FLAG=""
if [ ! -z $7 ]; then
  FLAG=$7
  echo "The flag is $7 and full command is..."
fi
if [ ! -z $8 ]; then
  SUFFIX=$8
fi

iterate=0
#for mp in 10 100
for mp in $(seq $MPBEGIN 1000 $MPEND)
#for mp in 10 50 100
do
  for ri in $(seq $RIBEGIN $RIEND)
  do
    echo "roslaunch mixmcl ${MCLPKG}.launch max_particles:=${mp} resample_interval:=${ri} suicide:=true global_localization:=true ${FLAG} > /dev/null"
    echo "${MCLPKG}_mp${mp}_ri${ri}${SUFFIX}"
    DIR="/home/jolly/ex3/topleft/${MCLPKG}_mp${mp}_ri${ri}${SUFFIX}"
    #DIR="/home/jolly/ex3/topleft_pt/${MCLPKG}_mp${mp}_ri${ri}${SUFFIX}"
    #DIR="/home/jolly/ex3/whole/${MCLPKG}_mp${mp}_ri${ri}${SUFFIX}"
    test -d ${DIR} && { echo "${DIR} exists"; } || { echo "${DIR} doesn't exist." && mkdir ${DIR} && echo "mkdir ${DIR}" || { echo "cannot mkdir ${DIR}"; exit 1; } }
    for (( i = 0 ; i < $RUNS ; i=$i+1 ))
    do
      iterate=$(($iterate+1))
      echo "${iterate}-th iterate"
      #roslaunch mixmcl ${MCLPKG}.launch max_particles:=${mp} resample_interval:=${ri} suicide:=true global_localization:=false ${FLAG} > /dev/null 
      roslaunch mixmcl ${MCLPKG}.launch max_particles:=${mp} resample_interval:=${ri} suicide:=true global_localization:=true ${FLAG} > /dev/null 
    done
    mv /home/jolly/.ros/${MCLPKG}_mp${mp}_ri${ri}*_2018*.bag ${DIR} && echo "moved bag files to ${DIR}" || { echo "cannot move bag files to ${DIR}"; exit 1; }
    echo "analysing ${DIR}/*.bag"
    rosrun mcl_stat mcl_stat true ${DIR}/*.bag > /dev/null 2>&1
    #echo "moving ${DIR} to ${DEST_DIR}" && mv ${DIR} ${DEST_DIR} && echo "moved ${DIR} to ${DEST_DIR}" || { echo "cannot move ${DIR} to ${DEST_DIR}"; exit 1; }
  done
done
exit 0
