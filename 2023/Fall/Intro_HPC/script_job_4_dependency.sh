#!/bin/bash
#SBATCH --job-name=job_4_dependency
#SBATCH --account=ctbp-onuchic
#SBATCH --partition=ctbp-onuchic
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00
#SBATCH --mem-per-cpu=100M
#SBATCH -e slurm-%A_%a-%x.err
#SBATCH -o slurm-%A_%a-%x.out
#SBATCH --array=1-8

BASE_SLEEP_TIME=10  # Base sleep time in seconds
INCREMENT=5 # Incremental sleep time in seconds per task

# Check if the task ID is even. If so, add an extra 10 seconds
[ $(($SLURM_ARRAY_TASK_ID % 2)) -eq 0 ] && EXTRA_SLEEP=10 || EXTRA_SLEEP=0

# Calculate total sleep time
TOTAL_SLEEP_TIME=$(($BASE_SLEEP_TIME + ($SLURM_ARRAY_TASK_ID * $INCREMENT) + $EXTRA_SLEEP))


# If it's the last job in the array, submit the dependent job
if [ $SLURM_ARRAY_TASK_ID -eq 1 ]; then
    sbatch --dependency=afterany:$SLURM_ARRAY_JOB_ID script_job_5.sh
fi

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

sleep $TOTAL_SLEEP_TIME

echo "Runtime Duration: $(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds."
