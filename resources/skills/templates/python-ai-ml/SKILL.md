# Python AI & Machine Learning

<!-- category: template -->

## Overview

Patterns and best practices for Python AI/ML projects — data analysis, model training, computer vision, image recognition, and production deployment.
[FILL: What ML/AI capabilities this project uses and why]

## Project Structure

```
[FILL: Adapt to project layout]
src/
  data/           # Data loading, preprocessing, augmentation pipelines
  models/         # Model definitions, architectures, custom layers
  training/       # Training loops, callbacks, hyperparameter configs
  inference/      # Prediction pipelines, model serving, batch inference
  evaluation/     # Metrics, visualization, experiment tracking
  utils/          # Shared utilities, logging, config parsing
notebooks/        # Exploratory analysis, prototyping (not production code)
configs/          # Training configs, model hyperparameters (YAML/TOML)
data/             # Raw and processed datasets (gitignored, DVC-tracked)
models/           # Saved model checkpoints and artifacts (gitignored)
tests/            # Unit and integration tests for pipelines
```

## Framework Selection

| Use Case | Recommended | Why |
|----------|-------------|-----|
| Research / prototyping | PyTorch | Eager execution, debugging, largest research ecosystem |
| Production training | PyTorch + Lightning | Structured training loops, multi-GPU, logging built-in |
| Quick experimentation | Keras 3 (multi-backend) | High-level API, runs on PyTorch/JAX/TensorFlow |
| Edge / mobile deployment | ONNX Runtime, TensorFlow Lite | Optimized inference, small footprint |
| Classical ML | scikit-learn | Simple API, well-tested, great for tabular data |
| Large-scale training | PyTorch + DeepSpeed / FSDP | Distributed training, model parallelism |
| JAX ecosystem | JAX + Flax / Equinox | Functional transforms, XLA compilation, TPU-native |

- Framework: [FILL: PyTorch / Keras / scikit-learn / JAX / combination]
- Version: [FILL: Framework version pinned in pyproject.toml]

## Data Analysis & Exploration

### Core libraries
- **pandas**: Tabular data manipulation, groupby, merge, pivot — the standard for structured data
- **polars**: Faster alternative to pandas for large datasets — lazy evaluation, Rust-backed, multi-threaded
- **NumPy**: Numerical arrays, linear algebra, random sampling — foundation of the ecosystem
- **SciPy**: Statistical tests, optimization, signal processing, sparse matrices

### Visualization
- **matplotlib**: Low-level plotting — full control, publication quality, the base layer
- **seaborn**: Statistical visualizations built on matplotlib — heatmaps, distributions, pair plots
- **plotly**: Interactive charts — dashboards, 3D plots, web embedding
- **Weights & Biases / MLflow**: Experiment tracking with automatic metric/artifact logging

### Best practices
- Keep exploratory analysis in notebooks; extract production logic into `.py` modules
- Profile data before modeling: distributions, missing values, class imbalance, outliers
- Document data provenance: source, collection date, preprocessing steps, known biases
- Use `pandas.DataFrame.describe()`, `.info()`, `.value_counts()` as first pass on any dataset
- [FILL: Primary data sources and formats used in this project]

## Computer Vision & Image Recognition

### Libraries
| Library | Purpose | Best For |
|---------|---------|----------|
| **torchvision** | Datasets, transforms, pretrained models | PyTorch CV pipelines |
| **timm** | 1000+ pretrained image models | SOTA classification, fine-tuning |
| **Ultralytics (YOLOv8/11)** | Object detection, segmentation, pose | Real-time detection, production |
| **OpenCV** | Image I/O, classical CV, video processing | Preprocessing, augmentation, legacy |
| **Albumentations** | Fast image augmentation | Training-time augmentation pipelines |
| **Segment Anything (SAM)** | Zero-shot segmentation | Interactive segmentation, annotation |
| **Hugging Face Transformers** | Vision transformers (ViT, DINOv2, CLIP) | Embeddings, zero-shot classification |
| **MediaPipe** | Face/hand/pose detection | Real-time on-device inference |
| **Pillow (PIL)** | Basic image I/O and manipulation | Loading, resizing, format conversion |

### Common CV tasks
- **Classification**: ResNet, EfficientNet, ViT via timm — fine-tune pretrained on your dataset
- **Object detection**: YOLOv8/11 (real-time), DETR (transformer-based), Faster R-CNN (two-stage)
- **Semantic segmentation**: U-Net (medical), DeepLabV3+, Mask2Former
- **Instance segmentation**: Mask R-CNN, YOLOv8-seg, SAM
- **Pose estimation**: YOLOv8-pose, MediaPipe, ViTPose
- **OCR**: EasyOCR, PaddleOCR, Tesseract (legacy)
- **Image embeddings**: CLIP, DINOv2 — for similarity search, zero-shot classification
- [FILL: Which CV tasks this project implements]

### Image preprocessing
```python
from torchvision import transforms

train_transform = transforms.Compose([
    transforms.RandomResizedCrop(224),
    transforms.RandomHorizontalFlip(),
    transforms.ColorJitter(brightness=0.2, contrast=0.2),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

val_transform = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])
```

- Always normalize to pretrained model's expected distribution (ImageNet defaults above)
- Use Albumentations for faster, more diverse augmentation (especially geometric transforms)
- Augment training data only — never augment validation/test sets
- [FILL: Image dimensions, color space, and preprocessing pipeline used]

## Model Training

### Training loop best practices
- Use PyTorch Lightning or Hugging Face Trainer to avoid boilerplate
- **Learning rate**: Start with 1e-3 (Adam) or 1e-2 (SGD); use cosine annealing or OneCycleLR scheduler
- **Batch size**: Largest that fits in GPU memory; use gradient accumulation for effective larger batches
- **Early stopping**: Monitor validation loss, patience of 5-10 epochs
- **Mixed precision**: `torch.amp` (fp16/bf16) — halves memory, speeds training 2-3x on modern GPUs
- **Gradient clipping**: `max_norm=1.0` to prevent exploding gradients (especially RNNs, transformers)

### Transfer learning pattern
1. Load pretrained model (ImageNet, COCO, or domain-specific)
2. Replace final classification head for your task
3. Freeze backbone, train head for 2-5 epochs (warmup)
4. Unfreeze backbone, train end-to-end with lower learning rate (1/10th of head LR)
5. Use layer-wise learning rate decay for deep models

### Hyperparameter management
- Store configs in YAML/TOML files, not hardcoded in training scripts
- Use Hydra, OmegaConf, or simple dataclasses for config management
- Track all hyperparameters with experiment tracker (W&B, MLflow, TensorBoard)
- [FILL: Hyperparameter management approach used in this project]

## Data Pipeline

### Dataset management
- **Hugging Face Datasets**: Streaming, caching, built-in preprocessing — best for NLP and multimodal
- **torchvision.datasets**: Standard CV benchmarks + `ImageFolder` for custom datasets
- **WebDataset**: Sharded tar files for large-scale training — efficient sequential I/O
- **DVC (Data Version Control)**: Track large data files and model artifacts alongside git

### DataLoader optimization
```python
DataLoader(
    dataset,
    batch_size=32,
    num_workers=4,           # parallel data loading (set to num CPU cores)
    pin_memory=True,         # faster CPU→GPU transfer
    persistent_workers=True, # avoid worker restart overhead
    prefetch_factor=2,       # prefetch 2 batches per worker
)
```

- `num_workers`: Start with `os.cpu_count()`, reduce if OOM
- Profile data loading vs training time — data loading should NOT be the bottleneck
- [FILL: Dataset size, format, and loading strategy]

## Evaluation & Metrics

### Classification metrics
- **Accuracy**: Only meaningful for balanced datasets
- **Precision / Recall / F1**: Per-class and macro-averaged — use for imbalanced data
- **AUROC / AUPRC**: Threshold-independent; AUPRC better for rare positives
- **Confusion matrix**: Always visualize to understand error patterns

### Detection & segmentation metrics
- **mAP@0.5 / mAP@0.5:0.95**: Standard for object detection (COCO-style)
- **IoU (Intersection over Union)**: Per-instance segmentation quality
- **Dice coefficient**: Preferred in medical imaging (equivalent to F1 for binary masks)

### Best practices
- Always report metrics on a held-out test set never seen during training or validation
- Use stratified splits for classification to preserve class distribution
- Report confidence intervals or standard deviation across multiple seeds
- [FILL: Primary metrics and evaluation protocol for this project]

## Inference & Deployment

### Model export
- **ONNX**: Universal format — `torch.onnx.export()` for cross-platform deployment
- **TorchScript**: `torch.jit.trace()` or `torch.jit.script()` for PyTorch-native serving
- **TensorRT**: NVIDIA-optimized inference — 2-5x speedup on NVIDIA GPUs
- **Core ML**: Apple devices — use `coremltools` to convert from PyTorch/ONNX
- **GGUF/GGML**: Quantized format for LLM inference on CPU (llama.cpp)

### Serving
- **FastAPI + Uvicorn**: Lightweight REST API for model inference
- **Triton Inference Server**: Multi-model, multi-framework, batching, GPU scheduling
- **BentoML**: Package models as deployable services with auto-generated APIs
- **vLLM**: High-throughput LLM serving with PagedAttention

### Production considerations
- **Quantization**: INT8/INT4 reduces model size 2-4x with minimal accuracy loss
- **Batching**: Batch inference requests for GPU efficiency — never process one-at-a-time
- **Preprocessing parity**: Ensure inference preprocessing exactly matches training
- **Model versioning**: Tag model artifacts with training config, dataset version, metrics
- [FILL: Deployment target and serving strategy for this project]

## Environment & Reproducibility

- Pin all dependencies in `pyproject.toml` with exact versions for reproducibility
- Set random seeds: `torch.manual_seed()`, `np.random.seed()`, `random.seed()`
- Use `torch.use_deterministic_algorithms(True)` for full reproducibility (slower)
- Track experiments: config, metrics, model checkpoints, git commit hash
- GPU setup: CUDA version in CI must match development; use Docker for consistency
- [FILL: Python version, CUDA version, key dependency versions]

## Key Constraints

- Never train on test data — enforce strict train/val/test splits
- Always version datasets alongside code (DVC, Hugging Face Hub, or checksums)
- Monitor for data drift in production — distribution shift degrades models silently
- GPU memory: profile with `torch.cuda.memory_summary()`, use gradient checkpointing for large models
- [FILL: Hardware constraints, latency requirements, accuracy targets]

## Where to Look

- PyTorch: https://pytorch.org/docs/
- torchvision: https://pytorch.org/vision/
- Hugging Face: https://huggingface.co/docs
- scikit-learn: https://scikit-learn.org/stable/
- Ultralytics: https://docs.ultralytics.com/
- timm: https://huggingface.co/docs/timm/
- Albumentations: https://albumentations.ai/docs/
- Lightning: https://lightning.ai/docs/pytorch/
- [FILL: Project-specific documentation and resources]

## Common Pitfalls

- Training/validation data leakage — augmented copies of the same image in both splits
- Forgetting to call `model.eval()` and `torch.no_grad()` during inference (BatchNorm, Dropout behave differently)
- ImageNet normalization on non-natural images (medical, satellite) — retrain normalization stats
- Class imbalance: use weighted loss, oversampling, or focal loss — not just accuracy
- Large model + small dataset = overfitting — use transfer learning, augmentation, regularization
- [FILL: Project-specific lessons learned]
