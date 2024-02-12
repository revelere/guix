(define-module (home)
  #:use-module (gnu services)
  #:use-module (gnu packages)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services xdg)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix transformations)
  #:use-module (rde packages)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features gtk)
  #:use-module (rde features xdg)
  #:use-module (rde features linux)
  ;;#:use-module (rde features android)
  #:use-module (rde features bluetooth)
  #:use-module (rde features terminals)
  #:use-module (rde features tmux)
  #:use-module (rde features wm)
  #:use-module (rde features shells)
  #:use-module (rde features shellutils)
  #:use-module (rde features emacs)
  #:use-module (rde features emacs-xyz)
  #:use-module (rde features guile)
  #:use-module (rde features fontutils)
  #:use-module (rde features image-viewers)
  #:use-module (rde features video)
  #:use-module (rde home services desktop)
  #:use-module (rde home services shells)
  #:use-module (rde home services emacs)
  #:use-module (rde home services video)
  #:use-module (dtao-guile home-service)
  #:use-module (dwl-guile home-service)
  #:use-module (dwl-guile patches)
  #:use-module (farg source)
  #:use-module (farg provider)
  #:use-module (farg theme)
  #:use-module (farg colors))

(define home-packages-service
  (simple-service
   'home-packages
   home-profile-service-type
   (append
    (strings->packages
     "git-minimal"
     "bubblewrap"
     "firefox"
     "torbrowser"
     "mullvadbrowser"
     "ungoogled-chromium"
     "steam"
     "gimp"
     "qbittorrent"
     "virt-manager"
     "wev"
     "imagemagick"
     "pavucontrol"
     "tumbler"
     "ffmpegthumbnailer"
     "ffmpeg"
     "thunar"
     ;;"adwaita-icon-theme"
     ;;"arc-theme"
     "font-google-roboto"
     "font-google-noto-sans-cjk"
     "font-google-noto-serif-cjk"))))

(define emacs-packages-service
  (simple-service
   'emacs-packages
   home-emacs-service-type
   (home-emacs-extension
    (elisp-packages
     (strings->packages
      "emacs-eat"
      "emacs-rainbow-mode"
      "emacs-rainbow-delimiters"
      "emacs-hl-todo"
      "emacs-yasnippet"
      "emacs-kind-icon"
      "emacs-ytdl"
      "emacs-minimap"
      "emacs-restart-emacs")))))

(define mpv-settings-service
  (simple-service
   'mpv-settings
   home-mpv-service-type
   (home-mpv-extension
    (mpv-conf
     `((global
        ((profile . high-quality)
         (vo . gpu-next)
         (hwdec . auto)
         (video-sync . display-resample)
         (interpolation . yes)
         (tscale . oversample)
         (ontop . no)
         (border . no)
         (osd-bar . no)
         (sub-use-margins . no)
         (volume . 100)
         (screenshot-directory . "~/pics/as/")
         (screenshot-template . "'%F - [%P]'")
         (screenshot-jpeg-quality . 95)
         (screenshot-jpeg-source-chroma . no)
         (cursor-autohide . 200)
         (fullscreen . yes)
         (save-position-on-quit . yes)
         (ytdl-format . "bestvideo[height<=?720][fps<=?30][vcodec!=?vp9]+bestaudio/best
"))))))))

;;(define xdg-desktop-entries-service
;;  (simple-service
;;   'xdg-desktop-entries
;;   home-xdg-mime-applications-service-type
;;   (home-xdg-mime-applications-configuration
;;    (desktop-entries
;;     (list
;;      (xdg-desktop-entry
;;       (file "emulator")
;;       (name "Emulator")
;;       (type 'application)
;;       (config
;;        `((exec . ,#~(string-join
;;                      (list
;;                       #$(file-append
;;                          (@ (gnu packages package-management) guix)
;;                          "/bin/guix")
;;                       "time-machine" "-C"
;;                       #$(project-file ".config/guix/channels.scm") "--"
;;                       "shell" "-C" "-N" "--emulate-fhs"
;;                       "--share=/tmp/.X11-unix" "--share=/dev/shm"
;;                       "--expose=/etc/machine-id" "--share=$HOME"
;;                       "--preserve='^ANDROID'" "--preserve='^DISPLAY$'"
;;                       "--preserve='^XAUTHORITY$'" "--share=/dev/kvm"
;;                       "--share=/dev/video0" "--share=/dev/dri"
;;                       "-m" #$(project-file
;;                               "android.scm")
;;                       "--" "env" "DISPLAY=:0"
;;                       #$(string-append "LD_LIBRARY_PATH="
;;                                        "/lib:/lib/nss:"
;;                                        "~/.android/emulator/lib64/qt/lib:"
;;                                        "~/.android/emulator/lib64")
;;                       "~/.android/emulator/emulator" "-show-kernel" "-gpu"
;;                       "swiftshader_indirect" "-camera-back" "webcam0"
;;                       "-avd" "whatsapp_bridge" "-no-snapshot")))
;;          (icon . "android")
;;          (comment . "Run an Android emulator")))))))))

(define extra-gtk-settings
  `((gtk-cursor-blink . #f)
    (gtk-cursor-theme-size . 16)
    (gtk-decoration-layout . "")
    (gtk-dialogs-use-header . #f)
    (gtk-enable-animations . #t)
    (gtk-enable-event-sounds . #f)
    (gtk-enable-input-feedback-sounds . #f)
    (gtk-error-bell . #f)
    (gtk-overlay-scrolling . #t)
    (gtk-recent-files-enabled . #f)
    (gtk-shell-shows-app-menu . #f)
    (gtk-shell-shows-desktop . #f)
    (gtk-shell-shows-menubar . #f)
    (gtk-xft-antialias . #t)
    (gtk-xft-dpi . 92)
    (gtk-xft-hinting . #t)
    (gtk-xft-hintstyle . hintfull)
    (gtk-xft-rgba . none)))

(define (extra-gtk-css config)
  (define dark-theme? (get-value 'gtk-dark-theme? config))

  (let ((bg (if dark-theme? 'black 'white))
        (fg (if dark-theme? 'white 'black))
        (accent-bg (string->symbol (if dark-theme? "#afafef" "#d0d6ff")))
        (accent-fg (if dark-theme? 'black 'white))
        (secondary-bg (string->symbol (if dark-theme? "#323232" "#f8f8f8")))
        (secondary-fg (if dark-theme? 'white 'black))
        (tertiary-bg (string->symbol (if dark-theme? "#6272a4" "#f0f0f0")))
        (selection (string->symbol (if dark-theme? "#afafef" "#e8dfd1"))))
    `(((box button:hover)
       ((background . ,secondary-bg)
        (color . ,fg)
        (outline . none)
        (box-shadow . none)))
      ((widget button)
       ((background . none)
        (border . none)
        (color . ,fg)
        (box-shadow . none)))
      ((widget button:hover)
       ((background . ,secondary-bg)))
      (#((stack box > #{button:not(:checked)}#)
         (.titlebar #{button:not(:checked)}#)
         (row #{button:not(:checked)}#)
         #{button.file:not(:checked)}#
         #{button.lock:not(:checked)}#
         #{button.image-button:not(:checked)}#
         #{button.text-button:not(:checked)}#
         #{button.toggle:not(:checked)}#
         #{button.slider-button:not(:checked)}#)
       ((-gtk-icon-shadow . none)
        (background . none)
        (color . ,fg)
        (border . (1px solid ,secondary-bg))
        (outline . none)
        (box-shadow . none)
        (text-shadow . none)))
      (#((stack box #{button:hover:not(:checked)}#)
         (.titlebar #{button:hover:not(:checked)}#)
         (row #{button:hover:not(:checked)}#)
         #{button.file:hover:not(:checked)}#
         #{button.lock:hover:not(:checked)}#
         #{button.image-button:hover:not(:checked)}#
         #{button.slider-button:hover:not(:checked)}#)
       ((background . none)))
      (button:checked
       ((background . ,tertiary-bg)
        (color . ,fg)
        (border . (1px solid ,tertiary-bg))))
      (image
       ((color . ,fg)))
      (image:disabled
       ((color . ,secondary-fg)))
      ((row:selected image)
       ((color . ,tertiary-bg)))
      ((row:selected button:hover)
       ((background . none)))
      ((button image)
       ((-gtk-icon-effect . none)
        (-gtk-icon-shadow . none)
        (color . ,fg)))
      ((headerbar button.toggle)
       ((border-radius . 20px)))
      (#((headerbar button.toggle)
         (stack stackswitcher button:checked)
         radio:checked
         (header button))
       ((background . ,tertiary-bg)
        (color . ,fg)
        (text-shadow . none)
        (border . (1px solid ,tertiary-bg))
        (box-shadow . none)))
      (#((button.color colorswatch)
         (colorswatch overlay))
       ((box-shadow . none)
        (border . none)))
      ((filechooser widget button)
       ((border . (1px solid ,secondary-bg))))
      (#((combobox entry)
         (combobox box)
         (combobox box button))
       ((background . ,secondary-bg)
        (color . ,fg)
        (border . none)
        (outline . none)
        (box-shadow . none)))
      ((combobox button)
       ((border . none)))
      ((combobox button:checked)
       ((background . none)
        (border . none)))
      (button.emoji-section:checked
       ((border . none)))
      (radiobutton
       ((outline . none)))
      ((radiobutton radio)
       ((color . ,bg)
        (background . ,bg)
        (border . none)))
      ((radiobutton radio:checked)
       ((background . ,accent-bg)
        (color . ,secondary-fg)))
      ((radiobutton box)
       ((background . none)
        (border-color . ,fg)))
      (checkbutton
       ((outline . none)))
      (#(check
         (modelbutton radio))
       ((background . ,secondary-bg)
        (color . ,fg)
        (border . none)))
      (#((checkbutton check:checked)
         (modelbutton check:checked)
         (treeview check:checked)
         (modelbutton radio:checked))
       ((background . ,accent-bg)
        (color . ,accent-fg)))
      (#((stackswitcher #{button:not(:checked)}#)
         #{radio:not(:checked)}#)
       ((background . ,secondary-bg)
        (color . ,secondary-fg)
        (border . (1px solid ,secondary-bg))
        (box-shadow . none)
        (text-shadow . none)))
      (switch
       ((background . ,secondary-bg)))
      (#(switch switch-slider)
       ((border-color . ,tertiary-bg)
        (box-shadow . none)))
      (switch:checked
       ((background . ,accent-bg)))
      ((switch:checked image)
       ((color . ,accent-fg)))
      (#((switch slider) (switch slider:disabled))
       ((background . ,tertiary-bg)))
      (label
       ((background . none)
        (text-shadow . none)))
      (label.keycap
       ((box-shadow . (0 -3px ,secondary-bg inset))
        (border-color . ,secondary-bg)))
      ((label link:link)
       ((color . ,accent-bg)
        (caret-color . ,accent-bg)
        (text-decoration-color . ,accent-bg)
        (text-decoration-line . none)))
      (spinbutton
       ((box-shadow . none)))
      ((spinbutton button)
       ((background . ,secondary-bg)
        (-gtk-icon-shadow . none)
        (border . none)))
      (#{spinbutton:not(:disabled)}#
       ((background . ,secondary-bg)
        (border . none)
        (color . ,fg)))
      (#(expander (expander title:hover > arrow))
       ((color . ,fg)))
      (modelbutton
       ((outline . none)))
      (modelbutton.flat:hover
       ((background . ,secondary-bg)))
      (window.background
       ((background . ,bg)
        (color . ,fg)))
      (decoration
       ((background . ,bg)
        (border-radius . (15px 15px 0 0))
        (border . none)
        (padding . 0)))
      (.titlebar
       ((background . ,bg)
        (color . ,fg)
        (border-color . ,secondary-bg)))
      (box
       ((background . ,bg)))
      ((box label)
       ((color . ,fg)))
      ((box frame border)
       ((border-color . ,secondary-bg)))
      (#(stack separator (filechooser paned separator))
       ((background . ,secondary-bg)))
      ((stack box)
       ((background . transparent)))
      (#(viewport list (viewport grid))
       ((background . ,bg)))
      ((viewport list row)
       ((outline . none)
        (background . none)))
      ((viewport row:selected)
       ((color . ,accent-fg)
        (background . ,accent-bg)
        (outline . none)))
      ((viewport row:selected label)
       ((color . ,accent-fg)))
      ((viewport #{row:hover:not(:selected)}#)
       ((background . none)))
      ((viewport row:selected > box label)
       ((color . ,accent-fg)))
      (treeview.view
       ((background . ,secondary-bg)
        (color . ,fg)
        (border-color . ,secondary-bg)
        (outline . none)))
      ((treeview:selected treeview:active)
       ((background . ,accent-bg)
        (color . ,accent-fg)))
      ((treeview header button)
       ((background . ,bg)
        (border . none)))
      (scrolledwindow
       ((border-color . ,secondary-bg)
        (background . ,tertiary-bg)))
      (#((scrolledwindow overshoot.top)
         (scrolledwindow overshoot.bottom))
       ((outline . none)
        (box-shadow . none)
        (background . none)
        (border . none)))
      (#((stack scrolledwindow viewport)
         (window stack widget))
       ((background . ,bg)
        (color . ,fg)))
      (box.view.vertical
       ((border . none)
        (box-shadow . none)
        (background . ,bg)))
      ((scrolledwindow textview text)
       ((background . ,bg)
        (color . ,fg)))
      (header
       ((background . ,bg)
        (border-color . ,secondary-bg)))
      ((header tabs label)
       ((color . ,fg)))
      ((header tabs tab)
       ((background . ,bg)))
      (#(notebook.frame
         (frame.border-ridge border)
         (frame.border-groove border)
         (frame.border-outset border)
         (frame.border-inset border))
       ((border-color . ,secondary-bg)))
      ((noteboox box)
       ((background . ,bg)
        (color . ,fg)))
      ((notebook header tabs tab)
       ((outline . none)))
      ((header tabs #{tab:not(:checked):hover}#)
       ((box-shadow . none)))
      ((notebook header.left tabs tab:checked)
       ((box-shadow . (-4px 0 ,accent-bg inset))))
      ((notebook header.right tabs tab:checked)
       ((box-shadow . (4px 0 ,accent-bg inset))))
      ((notebook header.bottom tabs tab:checked)
       ((box-shadow . (0 4px ,accent-bg inset))))
      ((notebook header.top tabs tab:checked)
       ((box-shadow . (0 -4px ,accent-bg inset))))
      ((notebook header.left tabs tab)
       ((border-right . (1px solid ,secondary-bg))))
      ((notebook header.right tabs tab)
       ((border-left . (1px solid ,secondary-bg))))
      ((notebook header.bottom tabs tab)
       ((border-top . (1px solid ,secondary-bg))))
      ((notebook header.top tabs tab)
       ((border-bottom . (1px solid ,secondary-bg))))
      (#((searchbar revealer box)
         (revealer frame.app-notification)
         (actionbar revealer box))
       ((background . ,tertiary-bg)
        (border-color . ,secondary-bg)))
      (#((searchbar revealer frame)
         (revealer frame.app-notification))
       ((background . ,tertiary-bg)
        (border . (1px solid ,secondary-bg))))
      (#((searchbar revealer box)
         (revealer frame.app-notification)
         (actionbar revealer box))
       ((background . ,tertiary-bg)
        (border-color . ,secondary-bg)))
      (toolbar
       ((background . ,bg)
        (color . ,fg)))
      (paned
       ((background . ,bg)
        (color . ,fg)))
      (paned
       ((background . ,bg)))
      ((flowboxchild grid)
       ((border-color . ,secondary-bg)))
      (#(menu .menu .context-menu)
       ((margin . 0)
        (padding . 0)
        (box-shadow . none)
        (background-color . ,bg)
        (border . (1px solid ,tertiary-bg))))
      (#((.csd menu)
         (.csd .menu)
         (.csd .context-menu))
       ((border . none)))
      (#((menu menuitem)
         (.menu menuitem)
         (.context-menu menuitem))
       ((transition . (background-color 75ms #{cubic-bezier(0, 0, 0.2, 1)}#))
        (min-height . 20px)
        (min-width . 40px)
        (padding . (4px 8px))
        (color . ,fg)
        (font . initial)
        (text-shadow . none)))
      (#((.menu menuitem:hover)
         (.menu menuitem:hover)
         (.context-menu menuitem:hover))
       ((transition . none)
        (background-color . #{alpha(currentColor, 0.08)}#)))
      (#((menu menuitem:disabled)
         (.menu menuitem:disabled)
         (.context-menu menuitem:disabled))
       ((color . #{alpha(currentColor, 0.5)}#)))
      (menubar
       ((background . ,bg)
        (color . ,fg)))
      ((menubar submenu)
       ((padding . 10px)))
      (scrollbar
       ((background . ,bg)
        (border . none)))
      ((scrollbar slider)
       ((background . ,tertiary-bg)
        (min-width . 6px)
        (min-height . 6px)
        (border . (1px solid ,fg))))
      (calendar
       ((background-color . ,bg)
        (color . ,fg)
        (margin . 0)
        (border-color . ,secondary-bg)))
      (calendar:selected
       ((background . ,accent-bg)
        (color . ,accent-fg)))
      (#(calendar.header calendar.button)
       ((background . ,accent-bg)))
      (calendar.button:hover
       ((color . ,accent-bg)))
      (iconview
       ((background . ,bg)
        (color . ,fg)))
      (iconview:selected
       ((background . ,accent-bg)
        (color . ,accent-fg)))
      ((scale contents trough)
       ((background . ,secondary-bg)
        (border-color . ,secondary-bg)
        (outline . none)))
      ((#{scale:not(.marks-after):not(.marks-before):not(:disabled)}#
        contents trough slider)
       ((background . ,secondary-bg)
        (border-color . ,bg)
        (box-shadow . none)))
      ((scale contents trough highlight)
       ((background . ,accent-bg)
        (border-color . ,accent-bg)))
      ((scale:disabled contents trough slider)
       ((background . ,secondary-bg)
        (border-color . ,bg)))
      (#((scale.marks-after contents trough slider)
         (scale.marks-before trough slider))
       ((background . ,secondary-fg)
        (border-radius . 50%)
        (border . (1px solid ,bg))
        (box-shadow . none)
        (min-height . 20px)
        (min-width . 20px)
        (margin . -7px)))
      (progressbar
       ((color . ,fg)))
      ((progressbar trough)
       ((background . ,secondary-bg)
        (border-color . ,secondary-bg)))
      ((progressbar trough progress)
       ((background . ,accent-bg)
        (border-color . ,accent-bg)))
      ((levelbar trough)
       ((background . ,secondary-bg)
        (border-color . ,secondary-fg)))
      ((levelbar trough block)
       ((border-color . ,secondary-fg)
        (background . ,secondary-fg)))
      ((levelbar trough block.filled)
       ((background . ,accent-bg)
        (border-color . ,accent-bg)))
      (entry
       ((background . ,secondary-bg)
        (color . ,fg)
        (border . none)))
      (entry:focus
       ((box-shadow . (0 0 0 1px ,accent-bg inset))))
      ((entry progress)
       ((border-color . ,accent-bg)))
      ((entry image)
       ((color . ,fg)))
      ((colorswatch overlay)
       ((border . none)))
      (selection
       ((background . ,selection)
        (color . ,fg)))
      (dialog
       ((background . ,bg)
        (color . ,fg)))
      (popover
       ((background . ,bg)
        (color . ,fg)
        (border . none)
        (box-shadow . none)))
      (.dialog-box
       ((background . ,bg)))
      ((.dialog-vbox button)
       ((border-radius . 0))))))

;;; dwl-guile features

(define %wallpaper
  (origin
   (method url-fetch)
   (uri "https://img3.gelbooru.com/images/e4/57/e457f6ca85db565b960901a6dc7d9bae.jpg")
   (file-name "polizei.jpg")
   (sha256 (base32 "1545x1558rc01232ww0943phrm59icpp7haw5q81d8c41bmhrz7r"))))

;;(define %wallpaper (local-file "./pics/negev.png"))

(define %dark-theme
  (farg-source
   (theme
    (farg-theme
     (fg "#FFFFFF")
     (bg "#000000")
     (bg-alt "#212121")
     (accent-0 "#00BCFF")
     (accent-1 "#212121")
     (accent-2 "#F0F0F0")
     (alpha 0.8)
     (light? #f)
     (other '((red . "#ff5f59")))
     (wallpaper %wallpaper)))))

(define %light-theme
  (farg-source
   (theme
    (farg-theme
     (fg "#000000")
     (bg "#FFFFFF")
     (bg-alt "#212121")
     (accent-0 "#9fc6ff")
     (accent-1 "#212121")
     (accent-2 "#F0F0F0")
     (alpha 0.8)
     (light? #t)
     (other '((red . "#a60000")))
     (wallpaper %wallpaper)))))

(define (bemenu-options palette)
  (define (%palette v) (format #f "~s" (palette v)))
  (list
   ;; "--ignorecase" "--hp" "10" "--cw" "1" "--ch" "20"
   "-H" "28" "--fn" "\"Iosevka 11\""
   "--tf" (%palette 'fg)
   "--tb" (format #f "~s" (farg:offset (palette 'bg) '20))
   "--ff" (%palette 'fg) "--fb" (%palette 'accent-2)
   "--nf" (%palette 'fg) "--nb" (%palette 'accent-2)
   ;; "--af" (%palette 'fg) "--ab" (%palette 'accent-2)
   ;; "--cf" (%palette 'fg) "--cb" (%palette 'accent-2)
   "--hf" (%palette 'fg) "--hb" (%palette 'accent-0)))

(define (extra-home-environment-variables-service palette)
  (simple-service
   'add-extra-home-environment-variables
   home-environment-variables-service-type
   `(("GPG_TTY" . "$(tty)")
     ("LESSHISTFILE" . "-")
     ("BEMENU_OPTS" . ,(string-join (bemenu-options palette))))))

(define* (grim-script #:key select? clipboard?)
  `(begin
     (use-modules (srfi srfi-19))
     (dwl:shcmd
      ,(file-append (@ (gnu packages image) grim) "/bin/grim")
      ,@(if select?
            `("-g" "\"$("
              ,(file-append (@ (gnu packages image) slurp) "/bin/slurp")
              ")\"")
            '())
      ,@(if clipboard?
            `("-" "|" ,(file-append (@ (gnu packages xdisorg) wl-clipboard)
                                    "/bin/wl-copy"))
            '("-t" "jpeg"
              (format #f "~a/pics/~a.jpg"
                      (getenv "HOME")
                      (date->string (current-date) "~Y~m~d-~H~M~S")))))))

(define (extra-home-wm-services palette)
  (let* ((dwl-guile-package (patch-dwl-guile-package
                             dwl-guile
                             #:patches (list %patch-xwayland
                                             %patch-focusmonpointer
                                             %patch-monitor-config)))
         (dtao-guile-package (@ (dtao-guile packages) dtao-guile))
         (brightnessctl (file-append (@ (gnu packages linux) brightnessctl)
                                     "/bin/brightnessctl"))
         (pamixer (file-append (@ (gnu packages pulseaudio) pamixer)
                               "/bin/pamixer"))
         (shepherd-configuration (home-shepherd-configuration
                                  (auto-start? #f)
                                  (daemonize? #f)))
         (shepherd (home-shepherd-configuration-shepherd
                    shepherd-configuration)))
    (list
     (service home-shepherd-service-type shepherd-configuration)
     (service home-dwl-guile-service-type
              (home-dwl-guile-configuration
               (package dwl-guile-package)
               (auto-start? #f)
               (config
                (list
                 `((setq inhibit-defaults? #t
                         border-px 2
                         border-color ,(palette 'bg)
                         focus-color ,(farg:offset (palette 'accent-0) 10)
                         root-color ,(palette 'bg-alt)
                         tags (map number->string (iota 5 1))
                         smart-gaps? #t
                         smart-borders? #t
                         gaps-oh 12
                         gaps-ov 12
                         gaps-ih 12
                         gaps-iv 12)
                   (set-xkb-rules '((layout . "br")
                                    (options . "ctrl:nocaps")))
                   (dwl:set-tag-keys "s" "s-S")
                   (set-keys "s-d" '(dwl:shcmd
                                     ,(file-append
                                       (@ (gnu packages xdisorg)
                                          j4-dmenu-desktop)
                                       "/bin/j4-dmenu-desktop")
                                     (format #f "--dmenu='~a'"
                                             ,(file-append
                                               (@ (gnu packages xdisorg)
                                                  bemenu)
                                               "/bin/bemenu")))
                             "s-x" '(dwl:shcmd
                                     ,(file-append
                                       (@ (gnu packages wm) swaylock-effects)
                                       "/bin/swaylock"))
                             "s-<return>" '(dwl:spawn "foot")
                             "s-e" '(dwl:spawn "emacsclient" "-c" "--eval" "(vterm)")
                             "s-f" '(dwl:spawn "./.sh/firefox.sh")
                             "s-m" '(dwl:spawn "./.sh/mullvadbrowser.sh")
                             "s-t" '(dwl:spawn "./.sh/torbrowser.sh")
                             "s-c" '(dwl:spawn "./.sh/chromium.sh")
                             "s-q" '(dwl:spawn "./.sh/qbittorrent.sh")
                             "s-s" '(dwl:spawn "steam")
                             "s-z" '(dwl:spawn "thunar")
                             "s-p" '(dwl:spawn "pavucontrol")
                             "s-i" '(dwl:focus-stack 1)
                             "s-o" '(dwl:focus-stack -1)
                             "s-h" '(dwl:change-master-factor 0.05)
                             "s-j" '(dwl:change-master-factor -0.05)
                             "s-k" 'dwl:kill-client
                             "S-s-<escape>" 'dwl:quit
                             "s-u" 'dwl:toggle-fullscreen
                             "s-l" '(dwl:cycle-layout 1)
                             "s-<page-up>" '(dwl:change-masters 1)
                             "s-<page-down>" '(dwl:change-masters -1)
                             "s-<space>" 'dwl:zoom
                             "s-S-0" '(dwl:view 0)
                             "s-\\" 'dwl:toggle-gaps
                             "s-[" '(dwl:change-gaps -6)
                             "s-]" '(dwl:change-gaps 6)
                             "s-S-<space>" 'dwl:toggle-floating
                             "s-<mouse-left>" 'dwl:move
                             "s-<mouse-right>" 'dwl:resize
                             "s-<mouse-middle>" 'dwl:toggle-floating
                             "<XF86PowerOff>" 'dwl:quit
                             "<XF86AudioMicMute>" '(dwl:shcmd ,pamixer "--source 5" "-t")
	                     "<XF86AudioMute>" '(dwl:shcmd ,pamixer "--toggle-mute")
	                     "<XF86AudioLowerVolume>" '(dwl:shcmd ,pamixer "--unmute" "--decrease 5")
	                     "S-<XF86AudioLowerVolume>" '(dwl:shcmd ,pamixer "--unmute" "--decrease 10")
	                     "<XF86AudioRaiseVolume>" '(dwl:shcmd ,pamixer "--unmute" "--increase 5")
	                     "S-<XF86AudioRaiseVolume>" '(dwl:shcmd ,pamixer "--unmute" "--increase 10")
	                     "<XF86MonBrightnessDown>" '(dwl:shcmd ,brightnessctl "set 5%-")
	                     "S-<XF86MonBrightnessDown>" '(dwl:shcmd ,brightnessctl "set 10%-")
	                     "<XF86MonBrightnessUp>" '(dwl:shcmd ,brightnessctl "set +5%")
	                     "S-<XF86MonBrightnessUp>" '(dwl:shcmd ,brightnessctl "set +10%")
                             "s-<insert>" ',(grim-script #:select? #t)
                             "s-<delete>" ',(grim-script))
                   (set-layouts 'default "[]=" 'dwl:tile
                                'monocle "|M|" 'dwl:monocle)
                   (set-monitor-rules '((name . "eDP-1")
                                        (masters . 1)
                                        (master-factor . 0.55)
                                        (width . 1366)
                                        (height . 768)
                                        (layout . default)))
                   ;;(set-rules '((title . "Android Emulator")
                   ;;             (floating? . #t)))
                   (add-hook!
                    dwl:hook-startup
                    (lambda ()
                      (dwl:start-repl-server)
                      (dwl:shcmd ,(file-append (@ (gnu packages xdisorg) wlsunset)
                                               "/bin/wlsunset") "-l -29.76 -L -51.12  -T 6500 -t 3000")
                      (dwl:shcmd ,(file-append (@ (gnu packages wm) swaybg)
                                               "/bin/swaybg") "-i" ,(palette 'wallpaper) "-m" "fill")
                      (dwl:shcmd
                       ,(file-append shepherd "/bin/shepherd")
                       "--logfile"
                       (format #f "~a/log/shepherd.log"
                               (or (getenv "XDG_STATE_HOME")
                                   (format #f "~a/.local/state"
                                           (getenv "HOME"))))))))))))
     (simple-service
      'add-rde-dtao-guile-service
      home-shepherd-service-type
      (list
       (shepherd-service
        (documentation "Run dtao-guile in RDE.")
        (provision '(rde-dtao-guile))
        (respawn? #t)
        (start
         #~(make-forkexec-constructor
            (list
             #$(file-append dtao-guile-package "/bin/dtao-guile")
             "-c" #$(string-append (getenv "HOME")
                                   "/.config/dtao-guile/config.scm"))
            #:user (getenv "USER")
            #:log-file
            #$(format #f "~a/log/dtao-guile.log"
                      (or (getenv "XDG_STATE_HOME")
                          (format #f "~a/.local/state" (getenv "HOME"))))))
        (stop #~(make-kill-destructor)))))
     (simple-service
      'restart-wm-services-on-change
      home-run-on-change-service-type
      `(("files/.config/dwl-guile/config.scm"
         ,#~(system* #$(file-append dwl-guile-package "/bin/dwl-guile")
                     "-e" "\"(dwl:reload-config)\""))
        ("files/.config/dtao-guile/config.scm"
         ,#~(system* #$(file-append shepherd "/bin/herd") "restart"
                     "rde-dtao-guile"))))
     (simple-service
      'run-dwl-guile-on-login-tty
      home-shell-profile-service-type
      (list
       #~(format #f "[ $(tty) = /dev/tty1 ] && exec ~a"
                 #$(program-file
                    "dwl-guile-start"
                    #~(system*
                       #$(file-append dwl-guile-package "/bin/dwl-guile")
                       "-c"
                       (string-append (getenv "HOME")
                                      "/.config/dwl-guile/config.scm"))))))
     (service home-dtao-guile-service-type
              (home-dtao-guile-configuration
               (package dtao-guile-package)
               (auto-start? #f)
               (config
                (dtao-config
                 (font "Iosevka:style=Regular:size=13")
                 (background-color (palette 'accent-2))
                 (foreground-color (palette 'fg))
                 (padding-left 0)
                 (padding-top 0)
                 (padding-bottom 20)
                 (border-px 0)
                 (modules '((ice-9 match)
                            (ice-9 popen)
                            (ice-9 regex)
                            (ice-9 rdelim)
                            (ice-9 textual-ports)))
                 (block-spacing 0)
                 (height 28)
                 (delimiter-right " ")
                 (left-blocks
                  (append
                   (map
                    (lambda (tag)
                      (let ((str (string-append
                                  "^p(8)" (number->string tag) "^p(8)"))
                            (index (- tag 1)))
                        (dtao-block
                         (events? #t)
                         (click `(match button
                                   (0 (dtao:view ,index))))
                         (render
                          `(cond
                            ((dtao:selected-tag? ,index)
                             ,(format #f "^bg(~a)^fg(~a)~a^fg()^bg()"
                                      (palette 'accent-0) (palette 'fg)
                                      str))
                            ((dtao:urgent-tag? ,index)
                             ,(format #f "^bg(~a)^fg(~a)~a^fg()^bg()"
                                      (palette 'red) (palette 'accent-0)
                                      str))
                            ((dtao:active-tag? ,index)
                             ,(format #f "^bg(~a)^fg(~a)~a^fg()^bg()"
                                      (farg:offset (palette 'bg) 20)
                                      (palette 'fg) str))
                            (else ,str))))))
                    (iota 5 1))
                   (list
                    (dtao-block
                     (events? #t)
                     (click `(dtao:next-layout))
                     (render
                      `(format #f "^p(8)~a^p(8)" (dtao:get-layout)))))))
                 (center-blocks
                  (list
                   (dtao-block
                    (events? #t)
                    (render
                     `(let ((title (dtao:title)))
                        (if (> (string-length title) 80)
                            (string-append (substring title 0 80) "...")
                            title))))))
                 (right-blocks
                  (list
                   (dtao-block
                    (interval 60)
                    (render
                     `(let* ((port (open-input-pipe
                                    ,(file-append
                                      (@ (gnu packages linux) acpi)
                                      "/bin/acpi")))
                             (str (get-string-all port)))
                        (close-port port)
                        (string-append
                         "^p(8)BAT: "
                         (match:substring
                          (string-match ".*, ([0-9]+%)" str) 1)
                         "^p(4)"))))
                   (dtao-block
                    (interval 1)
                    (render
                     `(let* ((port (open-input-pipe
                                    (string-append
                                     ,pamixer " --get-volume-human")))
                             (str (read-line port)))
                        (close-pipe port)
                        (unless (eof-object? str)
                          (string-append "^p(4)VOL: " str "^p(8)"))))
                    (click
                     `(match button
                        (0 (system
                            (string-append ,pamixer " --toggle-mute"))))))
                   (dtao-block
                    (interval 1)
                    (render
                     `(strftime "%A, %d %b (w.%V) %T"
                                (localtime (current-time))))))))))))))

(define (extra-home-desktop-services _ palette)
  (append
   (@@ (rde features base) %rde-desktop-home-services)
   (extra-home-wm-services palette)
   (list
    home-packages-service
    emacs-packages-service
    mpv-settings-service
    ;;xdg-desktop-entries-service
    (extra-home-environment-variables-service palette)
    (service home-udiskie-service-type
             (home-udiskie-configuration
              (config '((notify . #f))))))))

(rde-config-home-environment
 (rde-config
  (features
   (list
    (feature-user-info
     #:user-name "gabriel"
     #:full-name "Gabriel"
     #:email "nil"
     #:rde-advanced-user? #t
     #:emacs-advanced-user? #t)
    (feature-desktop-services
     #:default-desktop-home-services
     (farg:theme-provider %light-theme extra-home-desktop-services))
    (feature-gtk3
     #:gtk-dark-theme? #f
     #:gtk-theme #f
     #:extra-gtk-settings extra-gtk-settings
     #:extra-gtk-css extra-gtk-css)
    (feature-xdg
     #:xdg-user-directories-configuration
     (home-xdg-user-directories-configuration
      (music "$HOME/music")
      (videos "$HOME/vids")
      (pictures "$HOME/pics")
      (documents "$HOME/docs")
      (download "$HOME/dl")
      (desktop "$HOME")
      (publicshare "$HOME")
      (templates "$HOME")))
    ;; Emacs
    (feature-emacs
     ;;#:extra-init-el `((add-to-list 'default-frame-alist '(alpha-background . 90)))
     #:emacs-server-mode? #t
     #:default-application-launcher? #f)
    (feature-emacs-appearance)
    (feature-emacs-circadian)
    (feature-emacs-power-menu)
    (feature-emacs-all-the-icons)
    (feature-emacs-which-key)
    (feature-emacs-ace-window)
    (feature-emacs-modus-themes
     #:deuteranopia? #f
     #:headings-scaling? #t
     #:extra-modus-themes-overrides
     '((bg-mode-line-active bg-dim)))
    (feature-emacs-completion
     #:mini-frame? #f
     #:marginalia-align 'right)
    (feature-emacs-corfu
     #:corfu-doc-auto #f)
    (feature-emacs-smartparens
     #:paredit-bindings? #t
     #:show-smartparens? #t)
    (feature-emacs-time
     #:display-time? #f
     #:display-time-24hr? #f
     #:display-time-date? #f
     #:world-clock-time-format "%R %Z"
     #:world-clock-timezones
     '(("America/Sao_Paulo" "Sao_Paulo")
       ("Asia/Tokyo" "Tokyo")))
    (feature-emacs-vertico)
    (feature-compile)
    (feature-emacs-input-methods)
    (feature-emacs-dired)
    (feature-emacs-shell)
    (feature-emacs-eshell)
    (feature-emacs-geiser)
    (feature-emacs-elisp)
    (feature-emacs-eglot)
    (feature-emacs-guix)
    ;; CLI
    (feature-zsh)
    (feature-bash)
    (feature-direnv)
    (feature-foot)
    (feature-vterm)
    (feature-guile)
    (feature-tmux)
    ;; Desktop
    (feature-fonts)
    (feature-mpv)
    (feature-imv)
    (feature-yt-dlp)
    (feature-pipewire)
    ;;(feature-android)
    (feature-bluetooth)
    (feature-swayidle)
    (feature-swaylock
     #:swaylock (@ (gnu packages wm) swaylock-effects)
     #:extra-config '((screenshots)
                      (effect-blur . 7x5)
                      (clock)))))))
