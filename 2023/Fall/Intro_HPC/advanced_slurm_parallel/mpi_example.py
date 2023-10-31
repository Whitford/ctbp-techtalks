from mpi4py import MPI
import numpy as np
from time import time
import os

import os
os.environ["OMP_NUM_THREADS"] = "1"

def compute(data):
    total = np.sum(data)  # Perform summation
    return total

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

data_size = 10**8
data = np.random.rand(data_size) if rank == 0 else None

# Divide the data among processes
local_data_size = data_size // size
local_data = np.empty(local_data_size, dtype='d')
comm.Scatter(data, local_data, root=0)

# Each process computes the sum of its part
start_time = time()
local_sum = compute(local_data)
print(f"Rank: {rank}, Local Sum: {local_sum}, Time taken: {time() - start_time} seconds, Hostname: {os.uname()[1]}, CPU Cores: {os.sched_getaffinity(0)}")

# Reduce the partial sums to the root process
total_sum = comm.reduce(local_sum, op=MPI.SUM, root=0)

if rank == 0:
    print("Result:", total_sum)
    print("Duration:", time() - start_time, "seconds")
