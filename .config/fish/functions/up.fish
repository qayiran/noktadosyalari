function up --description "Arch/AUR sistëm güncëlleme ve bakım aracı"
    set -l do_check 0
    set -l do_all 0
    set -l do_mirrors 0
    set -l do_clean 0
    set -l do_diff 0
    set -l paru_args

    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case -h --help
                echo "Kullanım: up [seçenekler] [paru argümanları...]"
                echo ""
                echo "Seçenekler:"
                echo "  -c, --check     Kurmadan bekleyen repo + AUR güncëllemelerini ve sistëm durumunu göster"
                echo "  -a, --all       Ek araçları da güncëlle (rustup, pipx, fisher, fwupdmgr)"
                echo "  -m, --mirrors   Güncëllemeden önce reflector ile ayna listesini yenile"
                echo "  -C, --clean     Artık (orphan) paketleri ve eski önbellekleri temizle"
                echo "  -d, --diff      .pacnew/.pacsave dosyalarını delta + pacdiff ile incele"
                echo "  -h, --help      Bu yardım metnini göster"
                echo ""
                echo "Örnekler: up | up --check | up --all --clean | up --mirrors | up --noconfirm"
                return 0
            case -c --check
                set do_check 1
            case -a --all
                set do_all 1
            case -m --mirrors
                set do_mirrors 1
            case -C --clean
                set do_clean 1
            case -d --diff
                set do_diff 1
            case --
                set -l next (math $i + 1)
                if test $next -le (count $argv)
                    set -a paru_args $argv[$next..-1]
                end
                break
            case '*'
                set -a paru_args $argv[$i]
        end
        set i (math $i + 1)
    end

    # Yardımcı: pacdiff çalıştırıcı
    if test $do_diff -eq 1
        if not command -q pacdiff
            set_color red --bold
            echo "Hata: pacdiff kurulu değil (pacman-contrib gerekli)."
            set_color normal
            return 1
        end
        if command -q delta
            sudo env DIFFPROG="delta --paging=always" pacdiff -f
        else
            sudo env DIFFPROG="diff -u --color=always" pacdiff -f
        end
        return $status
    end

    # Yardımcı: salt-okunur kontro’l modu (up --check)
    if test $do_check -eq 1
        set_color cyan --bold
        echo "==> Bekleyen Güncëllemeler Kontro’l Ediliyor..."
        set_color normal

        if command -q checkupdates
            set -l repo_updates (checkupdates 2>/dev/null)
            set -l repo_status $status
            if test $repo_status -eq 0; and test (count $repo_updates) -gt 0
                set_color yellow --bold
                echo "Resmi depolar ("(count $repo_updates)" paket):"
                set_color normal
                printf '  %s\n' $repo_updates
            else if test $repo_status -eq 2
                set_color green
                echo "Resmi depolar güncel."
                set_color normal
            else
                set_color red
                echo "Resmi depo kontrolü başarısız oldu."
                set_color normal
            end
        end

        set -l aur_updates (paru -Qua 2>/dev/null)
        if test (count $aur_updates) -gt 0
            set_color yellow --bold
            echo "AUR ("(count $aur_updates)" paket):"
            set_color normal
            printf '  %s\n' $aur_updates
        else
            set_color green
            echo "AUR paketleri güncel."
            set_color normal
        end

        __up_health_report ""
        return 0
    end

    # 1) İsteğe bağlı ayna yenileme (--mirrors)
    if test $do_mirrors -eq 1
        if command -q reflector
            set_color cyan --bold
            echo "==> Aynalar reflector ile yenileniyor (TR, BG, RO, DE, NL)..."
            set_color normal
            sudo reflector --country TR,BG,RO,DE,NL --protocol https --latest 15 --age 24 --sort rate --save /etc/pacman.d/mirrorlist
            or begin
                set_color red --bold
                echo "Uyarı: reflector başarısız oldu, mevcut ayna listesiyle devam ediliyor."
                set_color normal
            end
        else
            set_color yellow
            echo "Uyarı: reflector kurulu değil, ayna yenileme atlandı."
            set_color normal
        end
    end

    # 2) Çekirdek/kritik paket sürümlerini güncëlleme öncesi kaydet
    set -l watch_pkgs linux linux-lts linux-zen nvidia-open nvidia nvidia-utils systemd mesa hyprland intel-ucode linux-firmware glibc
    set -l pre_versions
    for pkg in $watch_pkgs
        set -l ver (pacman -Q $pkg 2>/dev/null)
        if test -n "$ver"
            set -a pre_versions "$ver"
        end
    end

    # 3) Ana Arch + AUR sistëm güncëllemesi (Arch Habërleri dahil)
    set_color cyan --bold
    echo "==> Sistëm ve AUR güncëlleniyor (paru --newsonupgrade)..."
    set_color normal
    paru -Syu --newsonupgrade $paru_args
    set -l paru_status $status
    if test $paru_status -ne 0
        set_color red --bold
        echo "Güncëlleme tamamlanmadı (çıkış kodu: $paru_status). Zaman damgası güncëllenmedi."
        set_color normal
        return $paru_status
    end

    set -l now_ts (date +%s)
    if string match -rq '^[0-9]+$' -- "$now_ts"
        printf '%s\n' "$now_ts" > ~/.config/fish/.last_update_check.tmp
        and mv -f ~/.config/fish/.last_update_check.tmp ~/.config/fish/.last_update_check
    end

    # 4) İsteğe bağlı ikincil araçlar (--all)
    if test $do_all -eq 1
        if command -q rustup
            set_color cyan --bold
            echo "==> rustup güncëlleniyor..."
            set_color normal
            rustup update
        end

        if command -q pipx
            set_color cyan --bold
            echo "==> pipx paketleri güncëlleniyor..."
            set_color normal
            pipx upgrade-all
        end

        if functions -q fisher
            set_color cyan --bold
            echo "==> fisher eklëntileri güncëlleniyor..."
            set_color normal
            fisher update
        end

        if command -q fwupdmgr
            set_color cyan --bold
            echo "==> Donanım yazılımı (fwupdmgr) kontro’l ediliyor..."
            set_color normal
            fwupdmgr refresh 2>/dev/null
            fwupdmgr get-updates
            set -l fw_status $status
            if test $fw_status -eq 0
                set_color yellow
                echo "  Not: Yeni firmware kurmak için 'fwupdmgr update' çalıştırabilirsiniz."
                set_color normal
            end
        end
    end

    # 5) İsteğe bağlı temizlik (--clean)
    if test $do_clean -eq 1
        set_color cyan --bold
        echo "==> Artık paketler ve önbellek temizleniyor..."
        set_color normal
        paru -c
        paru -Sc
    end

    # 6) Kritik paket değişimlerini karşılaştır
    set -l updated_core
    for pkg in $watch_pkgs
        set -l post_ver (pacman -Q $pkg 2>/dev/null)
        if test -n "$post_ver"
            if not contains -- "$post_ver" $pre_versions
                set -a updated_core "$post_ver"
            end
        end
    end

    __up_health_report (string join ", " $updated_core)
    return 0
end

function __up_health_report --argument-names updated_core
    echo ""
    set_color cyan --bold
    echo "==> Sistëm Sağlık Özeti"
    set_color normal

    set -l warnings 0

    # 1) Yeniden başlatma gereksinimi
    set -l running_kernel (uname -r)
    set -l need_reboot 0
    if not test -d "/usr/lib/modules/$running_kernel"
        set need_reboot 1
    end
    if test -n "$updated_core"
        set need_reboot 1
    end
    if test $need_reboot -eq 1
        set warnings (math $warnings + 1)
        set_color yellow --bold
        echo "  [!] Yeniden başlatma önerilir:"
        set_color normal
        if not test -d "/usr/lib/modules/$running_kernel"
            echo "      Çalışan çekirdek ($running_kernel) artık diskte yok."
        end
        if test -n "$updated_core"
            echo "      Güncëllenen çekirdek/kritik paketler: $updated_core"
        end
    end

    # 2) DKMS modül doğrulaması (msi-ec, gpu-unlock vb.)
    if command -q dkms
        set -l dkms_lines (dkms status 2>/dev/null)
        set -l dkms_bad
        for line in $dkms_lines
            if not string match -rq ': installed' -- "$line"
                set -a dkms_bad "$line"
            end
        end

        # Kurulu linux çekirdek sürümü için her DKMS modülünün kurulu olduğundan emin ol
        set -l installed_linux (pacman -Q linux 2>/dev/null | awk '{print $2}' | string replace -r -- '\.arch' '-arch')
        if test -n "$installed_linux"; and test (count $dkms_lines) -gt 0
            set -l mod_names (printf '%s\n' $dkms_lines | awk -F'[,/]' '{print $1}' | sort -u)
            for mod in $mod_names
                if not printf '%s\n' $dkms_lines | string match -rq -- "^$mod/.*, $installed_linux, .*: installed"
                    set -a dkms_bad "$mod -> $installed_linux için kurulu değil!"
                end
            end
        end

        if test (count $dkms_bad) -gt 0
            set warnings (math $warnings + 1)
            set_color red --bold
            echo "  [!] DKMS sorunu tespit edildi (yeniden başlatmadan önce kontro’l et!):"
            set_color normal
            for bad in $dkms_bad
                echo "      $bad"
            end
        end
    end

    # 3) Başarısız systemd servisleri
    set -l sys_failed (systemctl --failed --no-legend --no-pager 2>/dev/null)
    set -l usr_failed (systemctl --user --failed --no-legend --no-pager 2>/dev/null)
    if test (count $sys_failed) -gt 0; or test (count $usr_failed) -gt 0
        set warnings (math $warnings + 1)
        set_color red --bold
        echo "  [!] Başarısız systemd servisleri:"
        set_color normal
        for u in $sys_failed
            echo "      [sistëm] $u"
        end
        for u in $usr_failed
            echo "      [kullanıcı] $u"
        end
    end

    # 4) .pacnew / .pacsave dosyaları
    set -l pacfiles (find /etc \( -name '*.pacnew' -o -name '*.pacsave' \) 2>/dev/null)
    if test (count $pacfiles) -gt 0
        set warnings (math $warnings + 1)
        set_color yellow
        echo "  [!] /etc altında "(count $pacfiles)" adet .pacnew/.pacsave dosyası var -> incelemek için: up --diff"
        set_color normal
    end

    # 5) Artık (orphan) paketler
    set -l orphans (pacman -Qtdq 2>/dev/null)
    if test (count $orphans) -gt 0
        set warnings (math $warnings + 1)
        set_color yellow
        set -l preview $orphans[1..(math "min(8, "(count $orphans)")")]
        echo "  [!] "(count $orphans)" artık paket var ("(string join ", " $preview)") -> temizlemek için: up --clean"
        set_color normal
    end

    # 6) Eski ayna listesi uyarısı (>45 gün)
    if test -f /etc/pacman.d/mirrorlist
        set -l ml_mtime (stat -c %Y /etc/pacman.d/mirrorlist 2>/dev/null)
        if test -n "$ml_mtime"
            set -l age_days (math "floor(("(date +%s)" - $ml_mtime) / 86400)")
            if test $age_days -gt 45
                set warnings (math $warnings + 1)
                set_color yellow
                echo "  [!] /etc/pacman.d/mirrorlist $age_days gündür güncëllenmedi -> yenilemek için: up --mirrors"
                set_color normal
            end
        end
    end

    if test $warnings -eq 0
        set_color green --bold
        echo "  [✓] Her şey temiz ve güncel!"
        set_color normal
    end
end
