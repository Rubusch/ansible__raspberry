;;; disable startup page

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;; melpa extension
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; no auto-indent at ENTER or the like
(setq electric-indent-mode nil)

(setq inhibit-startup-message 1)

;; Tab using spaces
(setq-default indent-tabs-mode nil)
(setq-default tab-width 8)

;;; Display column numbers
(column-number-mode 1)

;;; gedit like search
(setq isearch-highlight t)
(setq search-highlight t)
(setq-default transient-mark-mode t)

;; scroll one line
(setq scroll-step 1)
(setq scroll-conservatively 1)

;; find-file w/o default directory
(setq insert-default-directory nil)

;; find-file, writing another filename shadows suggestion
(setq file-name-shadow-mode 1)


;; backspace fun
(define-key global-map "\C-h" 'backward-delete-char)


;;; general programming
;; 80 column rule
;; TODO          

;; if emacs goodies is installed, following works
;; M-x toggle-show-trailing-whitespace-show-ws
(setq-default show-trailing-whitespace t)

;;; highlight mode
(global-font-lock-mode t)

;; fix the comment complete-in-red issue
(set-face-foreground 'font-lock-comment-face "red")
(set-face-foreground 'font-lock-comment-delimiter-face "red")

(setq font-lock-maximum-decoration t)

;;; highlight current line
;(global-hl-line-mode 1)

;;; Use a wide window: put comments further right
;(setq-default comment-column 65)

;;; highlight matching parenthesis
(show-paren-mode t)


;;; doxymacs
;; doxymacs is an .el package to use doxygen in emacs
;; aptitude install doxymacs

;; activate doxymacs keys:
;; C-c d ? will look up documentation for the symbol under the point.
;; C-c d r will rescan your Doxygen tags file.
;; C-c d f will insert a Doxygen comment for the next function.
;; C-c d i will insert a Doxygen comment for the current file.
;; C-c d ; will insert a Doxygen comment for a member variable on the current line (like M-;).
;; C-c d m will insert a blank multi-line Doxygen comment.
;; C-c d s will insert a blank single-line Doxygen comment.
;; C-c d @ will insert grouping comments around the current region.

;; start doxymacs when opening c/c++ file
;(add-hook 'c-mode-common-hook'doxymacs-mode)

;; individual settings, link doxymacs to fetch runtime info from doxygen
;(setq doxymacs-doxygen-tags "/media/shared/sources/NX_CORE2__etags/ApplicationTest/TAGS"
;"/media/shared/sources/NX_CORE2__etags/AuthenticationService/TAGS"
;"/media/shared/sources/NX_CORE2__etags/build_powerpc_debug/TAGS"
;"/media/shared/sources/NX_CORE2__etags/CanOpen/TAGS"
;"/media/shared/sources/NX_CORE2__etags/Car/TAGS"
;"/media/shared/sources/NX_CORE2__etags/CDD/TAGS"
;"/media/shared/sources/NX_CORE2__etags/Commons/TAGS"
;"/media/shared/sources/NX_CORE2__etags/Configuration/TAGS"
;"/media/shared/sources/NX_CORE2__etags/EmbeddedTM/TAGS"
;"/media/shared/sources/NX_CORE2__etags/Gate/TAGS"
;"/media/shared/sources/NX_CORE2__etags/Interfaces/TAGS"
;"/media/shared/sources/NX_CORE2__etags/KSC/TAGS"
;"/media/shared/sources/NX_CORE2__etags/MonitoringSupervisor/TAGS"
;"/media/shared/sources/NX_CORE2__etags/NX100NA/TAGS"
;"/media/shared/sources/NX_CORE2__etags/OMSServer/TAGS"
;"/media/shared/sources/NX_CORE2__etags/Portal/TAGS"
;"/media/shared/sources/NX_CORE2__etags/PORTServer/TAGS"
;"/media/shared/sources/NX_CORE2__etags/Processes/TAGS"
;"/media/shared/sources/NX_CORE2__etags/ServiceHandler/TAGS"
;"/media/shared/sources/NX_CORE2__etags/TMC/TAGS"
;"/media/shared/sources/NX_CORE2__etags/Tools/TAGS"
;"/media/shared/sources/NX_CORE2__etags/World/TAGS"
;"/media/shared/sources/NX_CORE2__etags/ZeroMOM/TAGS"
;)
;(setq doxymacs-doxygen-root "/media/shared/sources/NX_CORE2__html")




;; enable fancy doxygen highlight mode
;(defun my-doxymacs-font-lock-hook ()
;  (if (or (eq major-mode 'c-mode) (eq major-mode 'c++-mode))
;      (doxymacs-font-lock)))
;(add-hook 'font-lock-mode-hook 'my-doxymacs-font-lock-hook)

;; load doxymacs at startup
;(require 'doxymacs)



;;; general C/C++ indention
;(autoload 'c++-mode "C++ Editing Mode" t)
;(add-to-list 'auto-mode-alist '("\\.h$" . c++-mode))
;(cpp-font-lock-use-font-lock-faces t)


;;; general C
;; Linus' kernel formatting
(defun linux-c-mode ()
"C mode with adjusted defaults for use with the Linux kernel."
(interactive)
(c-set-style "K&R")
(setq tab-width 8)
;(setq tab-width 2)
(setq indent-tabs-mode t)
(setq c-basic-offset 8)
;(setq c-basic-offset 2)
)
(add-hook 'c-mode-hook 'linux-c-mode)


;;; kernel documentation's kernel formatting
;;
;; (defun c-lineup-arglist-tabs-only (ignored)
;;   "Line up argument lists by tabs, not spaces"
;;   (let* ((anchor (c-langelem-pos c-syntactic-element))
;;           (column (c-langelem-2nd-pos c-syntactic-element))
;;            (offset (- (1+ column) anchor))
;;             (steps (floor offset c-basic-offset)))
;;     (* (max steps 1)
;;        c-basic-offset)))

;; (add-hook 'c-mode-common-hook
;;           (lambda ()
;;             ;; Add kernel style
;;             (c-add-style
;;              "linux-tabs-only"
;;              '("linux" (c-offsets-alist
;;                         (arglist-cont-nonempty
;;                          c-lineup-gcc-asm-reg
;;                          c-lineup-arglist-tabs-only))))))

;; (add-hook 'c-mode-hook
;;           (lambda ()
;;             (let ((filename (buffer-file-name)))
;;               ;; Enable kernel mode for the appropriate files
;;               (when (and filename
;;                          (string-match (expand-file-name "/media/data1/lxr/source/")
;;                                        filename))
;;                 (setq indent-tabs-mode t)
;;                 (c-set-style "linux-tabs-only")))))



;;; C++ formatting
;;
;; (c-set-style "stroustrup")
;; (add-hook 'c-mode-hook
;;           (lambda () "Set c-c c-c to comment-region"
;;             (local-set-key "\c-c\C-c" 'comment-region)
;;             (setq (comment-column 65))))


;; ;;; cperl-mode customizations
;; (add-hook 'cperl-mode-hook
;;       '(lambda () "Set c-c c-c to comment-region"
;;          (local-set-key "\C-c\C-c" 'comment-region)
;;          (setq comment-column 65)))

;; (defun my-cperl-eldoc-documentation-function ()
;;   "Return meaningful doc string for `eldoc-mode'."
;;   (car
;;    (let ((cperl-message-on-help-error nil))
;;      (cperl-get-help))))

;; (add-hook 'cperl-mode-hook
;;           (lambda () "Set up eldoc mode for cperl"
;;             (set (make-local-variable 'eldoc-documentation-function)
;;                  'my-cperl-eldoc-documentation-function)))


;; goto-line command: M-g g <linenumber>
(global-set-key "\M-gg" 'goto-line)


;; hovering on parenthesis, use "%" / M-x goto-match-paren to jump to the
;; matching parenthesis.
(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis, otherwise insert
the character typed."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
    ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
    (t                    (self-insert-command (or arg 1))) ))
(global-set-key "%" `goto-match-paren)



;; emacsclient / server
;;
;; add the below code to your .emacs file. Call it w/ M-x server-shutdown
;; define function to shutdown emacs server instance
(defun server-shutdown ()
  "Save buffers, Quit, and Shutdown (kill) server"
  (interactive)
  (save-some-buffers)
  (kill-emacs)
  )




;; emacs and screen settings
;;
;; shall avoid 5B 5A 5C 5D appearing using CTRL and arrow keys
;;
;; (Note that the ^[ in the above example is not a caret followed by an opening
;; bracket, it's a single escape character which you type like this: C-q ESC.)
(defun terminal-init-screen ()
  "Terminal initialization function for GNU screen."
  (when (boundp 'input-decode-map)
    (define-key input-decode-map "[1;5C" [(control right)])
    (define-key input-decode-map "[1;5D" [(control left)]))
    (define-key input-decode-map "[1;5A" [(control up)])
    (define-key input-decode-map "[1;5B" [(control down)])
    )

;; turn this on, if ctrl left/right are not recognized correctly
(global-set-key "\M-[1;5C"    'forward-word)      ; ctrl+right
(global-set-key "\M-[1;5D"    'backward-word)     ; ctrl+left
(global-set-key "\M-[1;5A"    'backward-paragraph); ctrl+up
(global-set-key "\M-[1;5B"    'forward-paragraph) ; ctrl+down
(global-set-key "\M-[1;2C"    'forward-char)      ; shift+right
(global-set-key "\M-[1;2D"    'backward-char)     ; shift+left
(global-set-key "\M-[1;2A"    'previous-line)     ; shift+up
(global-set-key "\M-[1;2B"    'next-line)         ; shift+down




;; auto-completion.el - on the fly autocomplete
;(require 'auto-complete)
;(global-auto-complete-mode t)

;; bug fix eshell turns quit read-only
;; resource: https://lists.gnu.org/archive/html/bug-gnu-emacs/2014-05/msg00996.html
;(add-text-properties 0 (length prompt)
;    '(read-only t
;    font-lock-face eshell-prompt
;    front-sticky (font-lock-face read-only)
;    rear-nonsticky (font-lock-face read-only))



;; bitbake & yocto mode
;; download: https://github.com/mferland/bb-mode
(add-to-list 'load-path "~/.emacs.d/bb-mode")
(load "bb-mode.el")
(require 'bb-mode)
(setq auto-mode-alist (cons '("\\.bb$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.inc$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.bbappend$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.bbclass$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.conf$" . bb-mode) auto-mode-alist))

;; define matching other file
(setq cc-other-file-alist
      '(("\\.c"   (".h"))
       ("\\.cpp"   (".h"))
       ("\\.h"   (".c"".cpp"))))

;; define paths where to look files up
;; TODO adjust to sources
(setq ff-search-directories
      '("." "../src" "../include"))

;; bind the toggle function to a global key e.g. M-t
(global-set-key "\M-t" 'ff-find-other-file)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(evil yaml-mode tabbar session pod-mode muttrc-mode mutt-alias markdown-mode magit initsplit htmlize graphviz-dot-mode folding eproject diminish csv-mode company color-theme-modern browse-kill-ring boxquote bm bar-cursor apache-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
