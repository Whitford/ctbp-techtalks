#!/bin/bash
#SBATCH --job-name=job_3_array
#SBATCH --account=ctbp-onuchic
#SBATCH --partition=ctbp-onuchic
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00
#SBATCH --mem-per-cpu=100M
#SBATCH -e slurm-%A_%a-%x.err
#SBATCH -o slurm-%A_%a-%x.out
#SBATCH --array=1-8

echo "Array Task ID: $SLURM_ARRAY_TASK_ID"
echo "Job ID: $SLURM_JOB_ID"
echo "Hostname: $(hostname)"
echo "Memory Usage: $(free -h)"
echo "Node: $SLURM_NODELIST"
echo "CPUs: $SLURM_CPUS_ON_NODE"
echo "Threads: $(nproc --all)"
echo "Number of Nodes: $SLURM_NNODES"
echo "Number of Tasks: $SLURM_NTASKS"
echo "Cores/CPUs per Node: $SLURM_CPUS_ON_NODE"
sleep 240 # time in seconds
echo "Runtime Duration: $(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds."
