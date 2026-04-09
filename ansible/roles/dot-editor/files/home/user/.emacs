;; Use UTF-8.
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Disable backup and auto-save.
(setq backup-inhibited t)
(setq auto-save-default nil)

;; Use tabs
(setq tab-width 8)
(setq my-build-tab-stop-list tab-width)
(setq default-tab-width tab-width)
(setq c-indent-level tab-width)
(setq c-basic-offset tab-width)
(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (other . "linux")))
(setq indent-tabs-mode t)
(setq c-hungry-delete-key t)
(setq c-auto-newline t)
