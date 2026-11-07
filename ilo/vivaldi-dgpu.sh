#!/usr/bin/env fish

# ---- VIVALDI PERFORMANS BAŞLATICISI (RTX 4080 dGPU) ----

# 1. Açık Vivaldi süreçlerini kapat
killall -9 vivaldi-bin vivaldi-stable 2>/dev/null

# 2. GPU ve Shader önbelleklerini temizlë (Intel <-> NVIDIA çakışmasını önlemek için)
rm -rf ~/.config/vivaldi/Default/GPUCache \
       ~/.config/vivaldi/Default/GpuCache \
       ~/.config/vivaldi/Default/ShaderCache \
       ~/.config/vivaldi/ShaderCache \
       ~/.config/vivaldi/GrShaderCache \
       ~/.config/vivaldi/GraphiteDawnCache \
       ~/.config/vivaldi/SingletonLock \
       ~/.config/vivaldi/SingletonCookie \
       ~/.config/vivaldi/SingletonSocket

# 3. NVIDIA RTX 4080 PRIME Offload çevre değişkënlerini ayarla
set -e LIBVA_DRIVER_NAME
set -e NVD_BACKEND
set -gx __NV_PRIME_RENDER_OFFLOAD 1
set -gx __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0
set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
set -gx __VK_LAYER_NV_optimus NVIDIA_only

# 4. Vivaldi ortamını ve medya kodeklerini hazırla (~/.config/vivaldi-stable.conf'u atlayarak)
set -gx CHROME_WRAPPER /opt/vivaldi/vivaldi
set -gx HERE /opt/vivaldi
set -gx CHROME_VERSION_EXTRA stable
set -gx GNOME_DISABLE_CRASH_DIALOG SET_BY_GOOGLE_CHROME

for codec in /opt/vivaldi/libffmpeg.so.*
    if test -e "$codec"
        set -gx LD_PRELOAD "$codec"
        set -gx VIVALDI_PRELOADS "$codec"
        break
    end
end

# 5. Maksimum performans bayraklarıyla başlat
exec /opt/vivaldi/vivaldi-bin \
  --ozone-platform=x11 \
  --force-device-scale-factor=1.6 \
  --ignore-gpu-blocklist \
  --enable-gpu-rasterization \
  --enable-zero-copy \
  --use-gl=angle \
  --use-angle=gl \
  --enable-features=CanvasOopRasterization,AcceleratedVideoDecodeLinuxGL \
  --disable-features=Vulkan \
  $argv
