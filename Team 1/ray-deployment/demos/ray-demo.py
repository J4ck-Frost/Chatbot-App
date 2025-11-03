import ray
import time
import random

# Connect to GPU Ray cluster
print("Connecting to Ray cluster...")
ray.init('ray://ray-gpu-head-svc:10001')

print("=== RAY DISTRIBUTED COMPUTING DEMO ===")
print("Cluster Resources:", ray.cluster_resources())
print()

# Demo 1: Basic Remote Function
@ray.remote
def square_number(x):
    print(f"Processing number {x} on Ray cluster...")
    time.sleep(0.5)  # Simulate work
    result = x * x
    return result

print("Demo 1: Distributed Function Calls")
print("Running 5 square operations in parallel...")
start_time = time.time()
futures = [square_number.remote(i) for i in range(1, 6)]
results = ray.get(futures)
end_time = time.time()

print(f"Results: {results}")
print(f"Parallel execution time: {end_time - start_time:.2f} seconds")
print()

# Demo 2: GPU Task Simulation
@ray.remote(num_gpus=0.1)  # Request partial GPU (since we have 1 GPU total)
def simulate_gpu_training(model_name, epochs):
    print(f"Training {model_name} for {epochs} epochs on GPU...")
    time.sleep(1)  # Simulate GPU training time
    accuracy = random.uniform(0.85, 0.98)
    return {
        'model': model_name,
        'epochs': epochs,
        'accuracy': round(accuracy, 3),
        'status': 'completed'
    }

print("Demo 2: GPU Model Training Simulation")
print("Training 3 models in parallel on GPU...")
models = ['ResNet', 'BERT', 'GPT']
epochs_list = [10, 15, 20]

training_futures = [simulate_gpu_training.remote(model, epochs) 
                   for model, epochs in zip(models, epochs_list)]

training_results = ray.get(training_futures)
print("Training Results:")
for result in training_results:
    print(f"  {result['model']}: {result['accuracy']} accuracy after {result['epochs']} epochs")
print()

# Demo 3: Ray Actor (Stateful distributed class)
@ray.remote
class Counter:
    def __init__(self):
        self.count = 0
        print("Counter actor initialized")
    
    def increment(self):
        self.count += 1
        return self.count
    
    def get_count(self):
        return self.count

print("Demo 3: Distributed Actor (Stateful Object)")
print("Creating distributed counter...")
counter = Counter.remote()

print("Incrementing counter 5 times...")
increment_futures = [counter.increment.remote() for _ in range(5)]
increment_results = ray.get(increment_futures)
print(f"Increment results: {increment_results}")

final_count = ray.get(counter.get_count.remote())
print(f"Final counter value: {final_count}")
print()

# Demo 4: Data Processing Pipeline
@ray.remote
def process_batch(batch_id, data_size):
    print(f"Processing batch {batch_id} with {data_size} items...")
    time.sleep(0.3)  # Simulate processing
    processed_items = data_size * 2  # Simulate data transformation
    return {
        'batch_id': batch_id,
        'input_size': data_size,
        'output_size': processed_items,
        'processing_time': 0.3
    }

print("Demo 4: Data Processing Pipeline")
print("Processing 4 data batches in parallel...")
batch_sizes = [100, 150, 200, 175]
pipeline_futures = [process_batch.remote(i, size) 
                   for i, size in enumerate(batch_sizes)]

pipeline_results = ray.get(pipeline_futures)
print("Pipeline Results:")
total_input = sum(r['input_size'] for r in pipeline_results)
total_output = sum(r['output_size'] for r in pipeline_results)
print(f"  Total input items: {total_input}")
print(f"  Total output items: {total_output}")
print(f"  Batches processed: {len(pipeline_results)}")
print()

# Demo 5: Resource monitoring
print("Demo 5: Cluster Resource Monitoring")
print("Available resources:")
resources = ray.cluster_resources()
for resource, amount in resources.items():
    if not resource.startswith('node:'):
        print(f"  {resource}: {amount}")

print()
print("Active nodes:")
nodes = ray.nodes()
for i, node in enumerate(nodes):
    if node['Alive']:
        print(f"  Node {i+1}: {node['NodeManagerHostname']}")
        node_resources = node['Resources']
        print(f"    CPU: {node_resources.get('CPU', 0)}")
        print(f"    GPU: {node_resources.get('GPU', 0)}")
        print(f"    Memory: {node_resources.get('memory', 0) / (1024**3):.1f} GB")

print()
print("=== RAY DEMO COMPLETED ===")
print("Shutting down Ray connection...")
ray.shutdown()
print("Demo finished successfully!")