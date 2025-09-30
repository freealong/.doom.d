;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Yongqi Li"
      user-mail-address "liyq556@midea.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dark+)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(setq confirm-kill-emacs nil)

(setq company-ispell-dictionary (file-truename "~/org/words/english-words.txt"))
(setq company-ispell-available t)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; evil
(after! evil-escape
  (setq evil-escape-key-sequence "jk"))

;;; lsp
(setq lsp-clients-clangd-args '("-j=3"
                                "--background-index"
                                "--clang-tidy"
                                "--completion-style=detailed"
                                "--header-insertion=never"
                                "--header-insertion-decorators=0"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))

;;; projectile
(setq projectile-project-search-path '("~/projects"))
(map! :leader
      :desc "Find other file"
      "p o" #'projectile-find-other-file)

;;; magit
(after! magit (setq magit-save-repository-buffers t))

;;; org
;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq org-agenda-files '("~/org/Mail.org" "~/org/todo.org" "~/org/Inbox.org" "~/org/task_xyz.org" "~/org/task_personal.org"))
(use-package! org-roam
  :custom
  (org-roam-directory (file-truename "~/org"))
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :if-new (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n#+filetags: %^{tags}\n")
      :unnarrowed t)
     ("w" "work" plain
      "%?"
      :if-new (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n#+filetags: work %^{tags}\n")
      :unnarrowed t)
     )
   )
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n I" . org-roam-node-insert-immediate)
         ("C-c n b" . org-roam-capture-inbox)
         :map org-roam-dailies-map
         ("Y" . org-roam-dailies-capture-yesterday)
         ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies))

;; hacks for better productivity using org roam
(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (cons arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))
(defun org-roam-capture-inbox ()
  (interactive)
  (org-roam-capture- :node (org-roam-node-create)
                     :templates '(("i" "inbox" plain "* %?"
                                   :if-new (file+head "Inbox.org" "#+title: Inbox\n")))))

(use-package! org
  :bind (("C-c e m c" . org-export-markdown-to-clipboard)))

(defun org-export-markdown-to-clipboard ()
  (interactive)
  (let ((org-export-with-toc nil))
    (with-current-buffer (org-md-export-as-markdown)
      (clipboard-kill-region (point-min) (point-max))
      (kill-buffer-and-window))))

(use-package! ox-pandoc
  :config
  (setq org-pandoc-options-for-gfm '((wrap . "preserve")))
  )

;;; email
;; add mu4e path because I built mu by myself and installed it to /usr/local
;;(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e")
;;;; Each path is relative to the path of the maildir you passed to mu
;;
;;(defun capture-mail-follow-up (msg)
;;  (interactive)
;;  (call-interactively 'org-store-link)
;;  (org-capture nil "mf"))
;;
;;(defun capture-mail-read-later (msg)
;;  (interactive)
;;  (call-interactively 'org-store-link)
;;  (org-capture nil "mr"))
;;
;;(use-package! mu4e
;;  :ensure nil
;;  :defer 20
;;  :config
;;  (set-email-account!
;;   "xyzrobotics.com"
;;   '((mu4e-sent-folder       . "/xyzrobotics.com/Sent Items")
;;     (mu4e-drafts-folder     . "/xyzrobotics.com/Drafts")
;;     (mu4e-trash-folder      . "/xyzrobotics.com/Trash")
;;     (mu4e-refile-folder     . "/xyzrobotics.com/Archive")
;;     (smtpmail-smtp-user     . "frank.lee@xyzrobotics.com")
;;     ;; (user-mail-address      . "frank.lee@xyzrobotics.com")    ;; only needed for mu < 1.4
;;     (mu4e-compose-signature . "---\nFrank Lee\nhttps://www.xyzrobotics.com\nSent From Doom Emacs."))
;;   t)
;;
;;  (setq mu4e-maildir-shortcuts
;;      '(("/xyzrobotics.com/Sent Items" . ?s)
;;        ("/xyzrobotics.com/INBOX"      . ?i)
;;        ("/xyzrobotics.com/Trash"      . ?t)
;;        ("/xyzrobotics.com/Drafts"     . ?d)
;;        ("/xyzrobotics.com/bitbucket"  . ?b)
;;        ("/xyzrobotics.com/atlassian"  . ?a)))
;;
;;  ;; Add mu4e custom actions for our capture templates
;;  (add-to-list 'mu4e-headers-actions
;;               '("follow up" . capture-mail-follow-up) t)
;;  (add-to-list 'mu4e-view-actions
;;               '("follow up" . capture-mail-follow-up) t)
;;  (add-to-list 'mu4e-headers-actions
;;               '("read later" . capture-mail-read-later) t)
;;  (add-to-list 'mu4e-view-actions
;;               '("read later" . capture-mail-read-later) t)
;;
;;  ;; Refresh mail using isync every 10 minutes
;;  (setq mu4e-update-interval (* 10 60))
;;  (mu4e t)
;;)
;;
;;(use-package! org-msg
;;  :config
;;  (setq  org-msg-default-alternatives '((new            . (text html))
;;                                        (reply-to-html   . (text html))
;;                                        (reply-to-text   . (text html)))
;;         org-msg-greeting-fmt "
;;-----
;;/Frank Lee/\n
;;/www.xyzrobotics.com/\n
;;/May the Emacs force be with you./\n
;;/Sent From [[https://www.gnu.org/software/emacs/][Emacs]] powered by [[https://www.emacswiki.org/emacs/mu4e][mu4e]] and [[https://github.com/jeremy-compostella/org-msg][org-msg]]./
;;-----\n
;;"))
;;
;;;; org capture templates for mail
;;(nconc org-capture-templates
;;       '(("m" "Email Workflow")
;;         ("mf" "Follow Up" entry (file+olp "~/org/Mail.org" "Follow Up")
;;          "* TODO Follow up: %:fromname on %a\nSCHEDULED:%t\n\n%i" :immediate-finish t)
;;         ("mr" "Read Later" entry (file+olp "~/org/Mail.org" "Read Later")
;;          "* TODO Read: %:fromname on %a\nSCHEDULED:%t\n\n%i" :immediate-finish t)
;;         ))
;;
;;;; Call the oauth2ms program to fetch the authentication token
;;(defun fetch-access-token ()
;;  (with-temp-buffer
;;    (call-process "/home/xyz/.local/bin/oauth2ms" nil t nil "--encode-xoauth2")
;;    (buffer-string)))
;;
;;;; Add new authentication method for xoauth2
;;(cl-defmethod smtpmail-try-auth-method
;;  (process (_mech (eql xoauth2)) user password)
;;  (let* ((access-token (fetch-access-token)))
;;    (smtpmail-command-or-throw
;;     process
;;     (concat "AUTH XOAUTH2 " access-token)
;;     235)))
;;
;;;; Register the method
;;(with-eval-after-load 'smtpmail
;;  (add-to-list 'smtpmail-auth-supported 'xoauth2))
;;
;;(setq message-send-mail-function   'smtpmail-send-it
;;  smtpmail-default-smtp-server "smtp.office365.com"
;;  smtpmail-smtp-server         "smtp.office365.com"
;;  smtpmail-stream-type  'starttls
;;  smtpmail-smtp-service 587)

;; LLM
;; (use-package! aidermacs
;;   :bind (("C-c a" . aidermacs-transient-menu))
;;   :custom
;;   (aidermacs-default-chat-mode 'architect)
;;   (aidermacs-default-model "ollama_chat/deepseek-r1:latest")
;;   (aidermacs-backend 'vterm))

(use-package! gemini-cli
  :bind-keymap (("C-c c" . gemini-cli-command-map))
  :custom ((gemini-cli-mode)
           (gemini-cli-terminal-backend 'vterm)))
