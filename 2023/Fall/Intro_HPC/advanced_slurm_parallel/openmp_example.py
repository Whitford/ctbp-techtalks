import numpy as np
from joblib import Parallel, delayed
import time
import os

def sum_part(arr, thread_id):
    print(f"Thread ID: {thread_id}, Hostname: {os.uname()[1]}, CPU Core: {os.sched_getaffinity(0)}")
    total = np.sum(arr)  # Perform summation
    return total

if __name__ == "__main__":
    size = 10**8
    n_threads = 8
    data = np.random.rand(size)

    start_time = time.time()
    
    results = Parallel(n_jobs=n_threads)(
        delayed(sum_part)(data[i::n_threads], i) for i in range(n_threads)
    )
    
    total_sum = np.sum(results)
    duration = time.time() - start_time

    print("Result:", total_sum)
    print("Duration:", duration, "seconds")
