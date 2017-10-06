#!/bin/bash --login
#$ -S /bin/bash
#$ -l h_rt=1:0:0
#$ -N GromacsBench
#$ -pe mpi 192
#$ -wd /home/mmm0074/benchmarks/ARCHER_apps/GROMACS/GromacsARCHERBench_master/run

cat $0

NUM_NODES=8

BENCHDIR=/home/mmm0074/benchmarks/ARCHER_apps/GROMACS/GromacsARCHERBench_master

module load gromacs/2016.3/intel-2017-update1

MDRUN="mdrun_mpi"

casename=nc2-cubic-md
timestamp=$(date '+%Y%m%d%H%M')

INPUTDIR=$BENCHDIR/inputTPR
TPRFILE=nsteps800.tpr

WORKDIR=/home/mmm0074/benchmarks/ARCHER_apps/GROMACS/gromacs_scratch

#hardware specific settings
CHIPS_PER_NODE=2
CORES_PER_CHIP=12

#choose number of MPI tasks per chip
TASKS_PER_CHIP=12

#choose number of hyperthreads per core
HTHREADS_PER_CORE=1 

#number of OpenMP threads per task is calculated 
export OMP_NUM_THREADS=$[($CORES_PER_CHIP*$HTHREADS_PER_CORE)/$TASKS_PER_CHIP]

#total number of tasks is calculated
tasks=$[$NUM_NODES*$CHIPS_PER_NODE*$TASKS_PER_CHIP]

rm -rf $WORKDIR
mkdir -p $WORKDIR
cd $WORKDIR

cp $INPUTDIR/$TPRFILE .

date
gerun $MDRUN -s $TPRFILE -deffnm $casename -ntomp $OMP_NUM_THREADS
date

echo
echo $casename.log
echo "------------"
resfile="${casename}_${NUM_NODES}nodes_${timestamp}.log"
mv $casename.log ${BENCHDIR}/run/${resfile}


