#!/bin/bash
#SBATCH --job-name=job_5_after_all_4
#SBATCH --account=ctbp-onuchic
#SBATCH --partition=ctbp-onuchic
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00
#SBATCH --mem-per-cpu=100M
#SBATCH -e slurm-%j-%x.err
#SBATCH -o slurm-%j-%x.out

# Your job commands go here
echo "Running script_job_5.sh after the job array completed."
sleep 120