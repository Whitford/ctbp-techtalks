#!/bin/bash
#SBATCH --job-name=job_2
#SBATCH --account=ctbp-onuchic
#SBATCH --partition=ctbp-onuchic
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:00:10
#SBATCH --mem-per-cpu=100M
#SBATCH -e slurm-%j-%x.err
#SBATCH -o slurm-%j-%x.out


echo "This script is running on "
sleep 240 # time in seconds
echo "hostname $(hostname)"
echo "Runtime Duration: $(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds."