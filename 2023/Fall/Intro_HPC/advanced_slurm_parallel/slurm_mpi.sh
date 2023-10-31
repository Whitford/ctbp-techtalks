#!/bin/bash
#SBATCH --job-name=mpiJob
#SBATCH --account=ctbp-onuchic
#SBATCH --partition=ctbp-onuchic
#SBATCH --output=result_%x.txt
#SBATCH --nodes=2
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --mem-per-cpu=2G
# conda install -c conda-forge mpi4py


module load GCC/12.2.0 OpenMPI/4.1.4 Anaconda3/2022.05
source /opt/apps/software/Anaconda3/2022.05/bin/activate
conda activate $HOME/openmm

# Run the MPI Python script
mpirun -n 8 python mpi_example.py

conda deactivate
