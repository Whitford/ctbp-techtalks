from mpi4py import MPI
import threading
import os
import numpy as np
from time import time

def compute(data):
    total = np.sum(data)  # Perform summation
    return total

def print_and_compute(rank, thread_id, data):
    print(f"Rank: {rank}, Hostname: {os.uname()[1]}, CPU Core: {os.sched_getaffinity(0)}, Thread ID: {thread_id}")
    start_time = time()
    local_sum = compute(data)
    print(f"Time taken by Rank {rank}, Thread ID {thread_id}: {time() - start_time} seconds")
    return local_sum

def main():
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    np.random.seed(42)  # Ensure consistent random numbers across runs
    data = np.random.rand(10**8 // size)  # Adjust size of data based on number of MPI processes

    threads = []
    results = []
    
    # Number of threads per MPI task
    num_threads = 2
    for _ in range(num_threads):
        thread = threading.Thread(target=lambda: results.append(print_and_compute(rank, threading.get_ident(), data)))
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()

    # Sum the results from all threads
    local_sum = np.sum(results)

    # Gather results from all processes
    total_sum = comm.reduce(local_sum, op=MPI.SUM, root=0)

    # Print the final result
    if rank == 0:
        print("Total Sum:", total_sum)

if __name__ == "__main__":
    main()
