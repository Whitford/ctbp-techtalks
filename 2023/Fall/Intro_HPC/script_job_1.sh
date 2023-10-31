#!/bin/bash
#SBATCH --job-name=job_1
#SBATCH --account=ctbp-onuchic
#SBATCH --partition=ctbp-onuchic
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --mem-per-cpu=100M
#SBATCH -e slurm-%j-%x.err
#SBATCH -o slurm-%j-%x.out

echo "Job ID: $SLURM_JOB_ID"
echo "Hostname: $(hostname)"
echo "Memory Usage: $(free -h)"
echo "Node: $SLURM_NODELIST"
echo "CPUs: $SLURM_CPUS_ON_NODE"
echo "Threads: $(nproc --all)"
echo "Number of Nodes: $SLURM_NNODES"
echo "Number of Tasks: $SLURM_NTASKS"
echo "Cores/CPUs per Node: $SLURM_CPUS_ON_NODE"
echo "Runtime Duration: $(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds."
