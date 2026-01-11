# 1. Очистка системных кешей
RUN --mount=type=cache,target=/var/cache/app,source=cache \
    rm -rf /var/cache/app/* || true

# 2. Очистка пакетного менеджера
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Очистка pip кеша
RUN pip cache purge

# 4. Очистка временных файлов
RUN find /tmp -type f -delete 2>/dev/null || true
# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# install custom nodes into comfyui (first node with --mode remote to fetch updated cache)
RUN comfy node install --exit-on-fail comfyui_fearnworksnodes@0.1.2 --mode remote
RUN comfy node install --exit-on-fail https://github.com/ShmuelRonen/multi-lora-stack.git --mode remote
RUN comfy node install --exit-on-fail https://github.com/ltdrdata/ComfyUI-Impact-Pack.git --mode remote
# После установки всех нод
RUN ln -sf /comfyui/custom_nodes/multi-lora-stack/multi_lora_stack.py /comfyui/custom_nodes/comfyui_fearnworksnodes/multi_lora_stack.py
# download models into comfyui
RUN comfy model download --url https://huggingface.co/ashllay/YOLO_Models/resolve/main/bbox/nipples_yolov8s.pt --relative-path models/ultralytics/bbox --filename nipples_yolov8s.pt
RUN comfy model download --url https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth --relative-path models/sams --filename sam_vit_b_01ec64.pth
RUN comfy model download --url https://huggingface.co/uooogh/nipples_yolov8s-seg/resolve/main/nipples_yolov8s-seg.pt --relative-path models/ultralytics/segm --filename nipples_yolov8s-seg.pt
RUN comfy model download --url https://huggingface.co/knifeayumu/StableDiffusionXL_Collection/resolve/main/animagineXL40_v4Opt.safetensors --relative-path models/checkpoints --filename animagineXL40_v4Opt.safetensors

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
