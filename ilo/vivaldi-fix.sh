#!/bin/fish

# 1. Kill zombies
killall -9 vivaldi-bin vivaldi-stable 2>/dev/null

# 2. CLEAR CACHE (Mandatory)
rm -rf ~/.cache/vivaldi/Default/Cache
rm -rf ~/.config/vivaldi/Default/GpuCache
rm -rf ~/.config/vivaldi/Default/ShaderCache
rm -rf ~/.config/vivaldi/GrShaderCache

# 3. Clean environment
set -e LIBVA_DRIVER_NAME
set -e NVD_BACKEND
set -e __GLX_VENDOR_LIBRARY_NAME
set -e __NV_PRIME_RENDER_OFFLOAD

# 4. Launch "Balanced Mode"
# GPU is ON for drawing (Fast/Cool), but OVERLAYS are OFF (Stable).
exec vivaldi-stable \
  --ozone-platform=wayland \
  --ignore-gpu-blocklist \
  --enable-features=VaapiVideoDecoder,VaapiVideoEncoder,UseOzonePlatform,CanvasOopRasterization \
  --disable-features=UseDav1dVideoDecoder,Vulkan,HardwareOverlays,ZeroCopy,OneCopy,DrDc \
  --use-gl=angle \
  --use-angle=gl \
  --disable-zero-copy
