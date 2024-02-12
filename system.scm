(define-module (system)
  #:use-module (gnu)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (gnu services avahi)
  #:use-module (gnu services networking)
  #:use-module (gnu services sound)
  #:use-module (gnu services pm)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services linux)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (gnu system locale)
  #:use-module (gnu system file-systems)
  #:use-module (guix packages)
  #:use-module (guix download))

(define %nonguix-key
  (origin
   (method url-fetch)
   (uri "https://substitutes.nonguix.org/signing-key.pub")
   (sha256 (base32 "0j66nq1bxvbxf5n8q2py14sjbkn57my0mjwq7k1qm9ddghca7177"))))

(operating-system
 (kernel linux-xanmod)
 (kernel-arguments (cons* "resume=/swap/swapfile"
                          "resume_offset=3569372"
                          "fsck.mode=skip"
                          "nvme_core.default_ps_max_latency_us=0"
                          ;;"pcie_aspm=off"
                          "mitigations=off"
                          "random.trust_cpu=off"
                          "amd_iommu=on"
                          "efi=disable_early_pci_dma"
                          "kernel.kptr_restrict=2"
                          "kernel.dmesg_restrict=1"
                          "kernel.unprivileged_bpf_disabled=1"
                          "net.core.bpf_jit_harden=2"
                          "dev.tty.ldisc_autoload=0"
                          "vm.unprivileged_userfaultfd=0"
                          "kernel.kexec_load_disabled=1"
                          "kernel.sysrq=4"
                          "kernel.unprivileged_userns_clone=0"
                          "kernel.perf_event_paranoid=3"
                          "net.ipv4.tcp_syncookies=1"
                          "net.ipv4.tcp_rfc1337=1"
                          "net.ipv4.conf.all.rp_filter=1"
                          "net.ipv4.conf.default.rp_filter=1"
                          "net.ipv4.conf.all.accept_redirects=0"
                          "net.ipv4.conf.default.accept_redirects=0"
                          "net.ipv4.conf.all.secure_redirects=0"
                          "net.ipv4.conf.default.secure_redirects=0"
                          "net.ipv6.conf.all.accept_redirects=0"
                          "net.ipv6.conf.default.accept_redirects=0"
                          "net.ipv4.conf.all.send_redirects=0"
                          "net.ipv4.conf.default.send_redirects=0"
                          "net.ipv4.icmp_echo_ignore_all=1"
                          "net.ipv4.conf.all.accept_source_route=0"
                          "net.ipv4.conf.default.accept_source_route=0"
                          "net.ipv6.conf.all.accept_source_route=0"
                          "net.ipv6.conf.default.accept_source_route=0"
                          "net.ipv6.conf.all.accept_ra=0"
                          "net.ipv6.conf.default.accept_ra=0"
                          "net.ipv6.conf.all.use_tempaddr=2"
                          "net.ipv6.conf.default.use_tempaddr=2"
                          "net.ipv4.tcp_sack=0"
                          "net.ipv4.tcp_dsack=0"
                          "net.ipv4.tcp_fack=0"
                          "net.ipv4.tcp_timestamps=0"
                          "kernel.yama.ptrace_scope=2"
                          "vm.mmap_rnd_bits=32"
                          "vm.mmap_rnd_compat_bits=16"
                          "fs.protected_symlinks=1"
                          "fs.protected_hardlinks=1"
                          "fs.protected_fifos=2"
                          "fs.protected_regular=2"
                          "slab_nomerge"
                          "init_on_alloc=1"
                          "init_on_free=1"
                          "page_alloc.shuffle=1"
                          "randomize_kstack_offset=on"
                          "vsyscall=none"
                          ;;"debugfs=off"
                          "pti=on"
                          ;;"oops=panic"
                          ;;"module.sig_enforce=1"
                          ;;"lockdown=confidentiality"
                          "loglevel=0"
                          ;;"kernel.core_pattern=|/bin/false"
                          "fs.suid_dumpable=0"
                          "vm.swappiness=1"
                          "modprobe.blacklist=dccp,sctp,rds,tipc,n-hdlc,ax25,netrom,x25,rose,decnet,econet,af_802154,ipx,appletalk,psnap,p8023,p8022,can,atm,cramfs,freevxfs,jffs2,hfs,hfsplus,squashfs,udf,cifs,nfs,nfsv3,nfsv4,ksmbd,gfs2,vivid,uvcvideo,firewire-core,thunderbolt,pcspkr,snd_pcsp,iTCO_wdt,radeon"
                          %default-kernel-arguments))

 (firmware (cons* amdgpu-firmware
		  atheros-firmware
		  realtek-firmware
                  %base-firmware))

 (initrd (lambda (file-systems . rest)
           (apply microcode-initrd
                  file-systems
                  #:initrd base-initrd
                  #:microcode-packages (list amd-microcode)
                  rest)))

 (locale "en_US.utf8")
 (locale-definitions (list (locale-definition (source "en_US")
                                              (name "en_US.UTF-8"))
	                   (locale-definition (source "ja_JP")
                                              (name "ja_JP.UTF-8"))))

 (timezone "America/Sao_Paulo")
 (keyboard-layout (keyboard-layout "br" #:options '("ctrl:nocaps")))
 (host-name "localhost")
 (users (cons* (user-account
                (name "gabriel")
                (comment "Gabriel")
                (group "users")
                (home-directory "/home/gabriel")
                (shell (file-append (@ (gnu packages shells) zsh) "/bin/zsh"))
                (supplementary-groups
                 '( "wheel" "netdev" "audio" "video" "lp" "libvirt" "kvm")))
               %base-user-accounts))

 (sudoers-file
  (plain-file "sudoers"
              (string-join '("root ALL=(ALL) ALL"
                             "%wheel ALL=(ALL) ALL"
			     "Defaults passwd_timeout=0"
			     "Defaults timestamp_type=global"
			     "Defaults timestamp_timeout=5"
			     "Defaults insults") "\n")))

 (packages (append
            (map specification->package
                 '("nss-certs"))
            %base-packages))

 (services (cons*
            (service nftables-service-type)
            (service earlyoom-service-type)
            (service virtlog-service-type)
            (service libvirt-service-type
                     (libvirt-configuration
                      (unix-sock-group "libvirt")))
            (service bluetooth-service-type
                     (bluetooth-configuration
                      (auto-enable? #t)))
            (service tlp-service-type
                     (tlp-configuration
                      (tlp-default-mode "BAT")
                      (cpu-scaling-governor-on-ac (list "performance"))
                      (cpu-scaling-governor-on-bat (list "powersave"))
                      (usb-autosuspend? #t)))
            (modify-services %desktop-services
                             (delete gdm-service-type)
	                     (delete avahi-service-type)
	                     (delete cups-pk-helper-service-type)
                             (delete modem-manager-service-type)
                             (delete usb-modeswitch-service-type)
                             (delete sane-service-type)
                             (delete pulseaudio-service-type)
                             (delete alsa-service-type)
                             (delete ntp-service-type)
                             (screen-locker-service-type config =>
                                                         (screen-locker-configuration
                                                          (name "swaylock")
                                                          (program (file-append (@ (gnu packages wm) swaylock-effects) "/bin/swaylock"))
                                                          (using-pam? #t)
                                                          (using-setuid? #f)))
                             (guix-service-type config =>
                                                (guix-configuration
                                                 (substitute-urls
                                                  (append (list "https://bordeaux-us-east-mirror.cbaines.net"
                                                                "https://substitutes.nonguix.org")
                                                          %default-substitute-urls))
				                 (authorized-keys
				                  (append (list %nonguix-key)
                                                          %default-authorized-guix-keys)))))))

 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets '("/efi"))
              (extra-initrd "/crypto_keyfile.cpio")
              (theme (grub-theme (image (local-file "./pics/wallpaper/Mushoku/roxy.png"))))))

 (mapped-devices (list (mapped-device
                        (source "/dev/nvme0n1p2")
                        (target "guix")
                        (type (luks-device-mapping-with-options
                               #:key-file "/crypto_keyfile.bin")))))

 (swap-devices (list (swap-space
                      (target "/swap/swapfile")
                      (dependencies mapped-devices))))

 (file-systems (append (list (file-system
                              (device (file-system-label "system"))
                              (mount-point "/")
                              (type "btrfs")
                              (flags '(no-atime))
                              (options "subvol=@,space_cache=v2,compress-force=zstd:1,discard=async")
                              (dependencies mapped-devices))
                             (file-system
                              (device (file-system-label "system"))
                              (mount-point "/boot")
                              (type "btrfs")
                              (flags '(no-atime no-dev no-suid no-exec))
                              (options "subvol=@boot")
                              (dependencies mapped-devices))
                             (file-system
                              (device (file-system-label "system"))
                              (mount-point "/gnu")
                              (type "btrfs")
                              (flags '(no-atime))
                              (options "subvol=@gnu")
                              (dependencies mapped-devices))
                             (file-system
                              (device (file-system-label "system"))
                              (mount-point "/home")
                              (type "btrfs")
                              (flags '(no-atime no-dev no-suid))
                              (options "subvol=@home")
                              (dependencies mapped-devices))
                             (file-system
                              (device (file-system-label "system"))
                              (mount-point "/var/log")
                              (type "btrfs")
                              (flags '(no-atime no-dev no-suid no-exec))
                              (options "subvol=@log")
                              (dependencies mapped-devices))
                             (file-system
                              (device (file-system-label "system"))
                              (mount-point "/anitya")
                              (type "btrfs")
                              (flags '(no-atime no-dev no-suid no-exec))
                              (options "subvol=@anitya")
                              (dependencies mapped-devices))
                             (file-system
                              (device (file-system-label "system"))
                              (mount-point "/.snapshots")
                              (type "btrfs")
                              (flags '(no-atime no-dev no-suid no-exec))
                              (options "subvol=@snapshots")
                              (dependencies mapped-devices))
                             (file-system
                              (device (file-system-label "system"))
                              (mount-point "/swap")
                              (type "btrfs")
                              (flags '(no-atime no-dev no-suid no-exec))
                              (options "subvol=@swap")
                              (dependencies mapped-devices))
                             (file-system
                              (mount-point "/tmp")
                              (device "none")
                              (type "tmpfs")
                              (flags '(no-atime no-dev no-suid)))
                             (file-system
                              (device (uuid "A424-5EFD" 'fat32))
                              (mount-point "/efi")
                              (type "vfat")
                              (flags '(no-atime no-dev no-suid no-exec))))
                       %base-file-systems)))
