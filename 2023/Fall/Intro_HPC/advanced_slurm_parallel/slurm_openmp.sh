#!/bin/bash
#SBATCH --job-name=openmpJob
#SBATCH --account=ctbp-onuchic
#SBATCH --partition=ctbp-onuchic
#SBATCH --output=result_%x.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=00:05:00
#SBATCH --mem-per-cpu=2G

export OMP_NUM_THREADS=8

module load GCC/12.2.0 OpenMPI/4.1.4 Anaconda3/2022.05
source /opt/apps/software/Anaconda3/2022.05/bin/activate
conda activate $HOME/openmm

python openmp_example.py