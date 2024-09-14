from enum import Enum
from queue import Queue
from threading import Thread
import time

class JobStatus(Enum):
    QUEUED = "queued"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"

class Job:
    def __init__(self, func, job_id):
        self.func = func
        self.job_id = job_id
        self.status = JobStatus.QUEUED
        self.result = ''

class JobQueue:
    def __init__(self):
        self.queue = Queue()
        self.is_running = True
        self.worker_thread = Thread(target=self._process_queue)
        self.worker_thread.start()
        self.jobs = {}

    def add_job(self, func, job_id):
        job = Job(func, job_id)
        self.queue.put(job)
        self.jobs[job.job_id] = job
        return job.job_id

    def _process_queue(self):
        while self.is_running:
            try:
                job = self.queue.get(timeout=1)
                self._execute_job(job)
                self.queue.task_done()
            except:
                continue

    def get_job_status(self, job_id):
        job = self.jobs.get(job_id)
        if job:
            if not job.result:
                job.result = 'No response'

            return {
                "id": job.job_id,
                "status": job.status.value,
                "result": job.result,
            }
        return None

    @staticmethod
    def _execute_job(job):
        print(f"Executing job: {job.job_id}")
        job.status = JobStatus.RUNNING
        try:
            job.result = job.func(job.job_id)
            time.sleep(20)
            job.status = JobStatus.COMPLETED
            print(f'Job {job.job_id} completed')
        except Exception as e:
            print('Job failed', e)
            job.status = JobStatus.FAILED
            job.result = str(e)

    def stop(self):
        self.is_running = False
        self.worker_thread.join()
