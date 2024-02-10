;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Start Doom-Emacs maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Semih Kacmaz"
      user-mail-address (getenv "EMAIL"))

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
(setq doom-theme 'doom-dracula)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Display line numbers everywhere
(global-display-line-numbers-mode 1)

;; Get rid of the annoying title bar in gnome and the latest macOS
;; (add-to-list 'default-frame-alist '(undecorated . t))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


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



;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-<tab>" . 'copilot-accept-completion-by-word)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("M-C-<down>" . 'copilot-accept-completion-by-line)
              ("M-C-<right>" . 'copilot-next-completion)
              ("M-C-<left>" . 'copilot-previous-completion)))


;; Change the activation mode of copilot
(defvar rk/copilot-manual-mode nil
  "When `t' will only show completions when manually triggered, e.g. via M-C-<return>.")

(defun rk/copilot-change-activation ()
  "Switch between three activation modes:
- automatic: copilot will automatically overlay completions
- manual: you need to press a key (M-C-<return>) to trigger completions
- off: copilot is completely disabled."
  (interactive)
  (if (and copilot-mode rk/copilot-manual-mode)
      (progn
        (message "deactivating copilot")
        (global-copilot-mode -1)
        (setq rk/copilot-manual-mode nil))
    (if copilot-mode
        (progn
          (message "activating copilot manual mode")
          (setq rk/copilot-manual-mode t))
      (message "activating copilot mode")
      (global-copilot-mode))))

(define-key global-map (kbd "M-C-<escape>") #'rk/copilot-change-activation)


;; Cancel copilot overlay with C-g
(defun rk/copilot-quit ()
  "Run `copilot-clear-overlay' or `keyboard-quit'. If copilot is
cleared, make sure the overlay doesn't come back too soon."
  (interactive)
  (condition-case err
      (when copilot--overlay
        (lexical-let ((pre-copilot-disable-predicates copilot-disable-predicates))
          (setq copilot-disable-predicates (list (lambda () t)))
          (copilot-clear-overlay)
          (run-with-idle-timer
           1.0
           nil
           (lambda ()
             (setq copilot-disable-predicates pre-copilot-disable-predicates)))))
    (error handler)))

(advice-add 'keyboard-quit :before #'rk/copilot-quit)



;; straigh.el related bootstrap code
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq package-enable-at-startup nil)



;; c3po settings
(use-package! c3po
  :straight (:host github :repo "d1egoaz/c3po.el")
  :config
  (setq c3po-api-key (getenv "OPENAI_API_KEY")))


;; Default droid
(defvar c3po-droids-alist
  '(
    (assistant . (:system-prompt "You are a helpful assistant."))
    (grammar-checker . (
                        :additional-pre-processors (c3po-show-diff-pre-processor)
                        :additional-post-processors (c3po-show-diff-post-processor)
                        :system-prompt "
I will communicate with you in any language and you will correct, spelling, punctuation errors, and enhance the grammar in my text.
You may use contractions and avoid passive voice.
I want you to only reply with the correction and nothing else, do not provide additional information, only enhanced text or the original text."
                        :prefix-first-prompt-with "Correct spelling and grammar. The raw text is:\n"))

    (developer . (:system-prompt "
I want you to act as a programming expert who can provide guidance, tips, and best practices for various programming languages.
You can review and analyze existing code, identify areas for optimization, and suggest changes to enhance performance, readability, and maintainability.
Please share insights on refactoring techniques, code organization, and how to follow established coding standards to ensure a clean and consistent codebase.
Please offer guidance on how to improve error handling, optimize resource usage, and implement best practices to minimize potential bugs and security vulnerabilities.
Lastly, offer advice on selecting the appropriate tools, libraries, and frameworks for specific projects, and assist with understanding key programming concepts, such as algorithms, data structures, and design patterns.
Your answers must be written in full and well-structured markdown. Code blocks must use the appropriate language tag."))

    (rewriter . (
                 :additional-post-processors (c3po-show-diff-post-processor)
                 :system-prompt "
I want you to act as my writing assistant with strong programming skills.
I'll converse with you in any language, and you can refine my writing.
Use contractions, avoid too much passive voice, and preserve the meaning.
Only provide the revised text.
All of my future messages aim to be improved."
                 :prefix-first-prompt-with "Rewrite this:\n"))
    )
  "Alist of droids with a Plist of properties.
Call `c3po-make-droid-helper-functions' to have the helper functions created.")






;; org-bullets settings
(setq org-bullets-face-name (quote org-bullet-face))
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(add-hook 'org-mode-hook 'org-indent-mode)
(setq org-bullets-bullet-list '("⬢" "◆" "▲" "■"))

;; use pdflatex to render tex files
(setq latex-run-command "pdflatex")

;; org-babel settings
;; Syntax highlightning in code blocks
(setq org-src-fontify-natively t)

;; Trying to fix indentation behaviour within code blocks.
;; THIS ALSO SEEMS TO BE CAUSING TROUBLE
(setq org-edit-src-content-indentation 0)
(setq org-src-tab-acts-natively t)
(setq org-src-preserve-indentation t)

;; Allow babel code execution without confirming it every time.
(setq org-confirm-babel-evaluate nil)

;; Change babel's python to python3 and use the advice from: https://kitchingroup.cheme.cmu.edu/blog/2016/05/29/Expanding-orgmode-py-to-get-better-org-python-integration/
(setq org-babel-python-command "python3")
;; (setq org-babel-default-header-args:python
;;       (cons '(:results . "output org drawer replace")
;;             (assq-delete-all :results org-babel-default-header-args)))



;; Available embedded languages for babel.
(org-babel-do-load-languages 'org-babel-load-languages
                              '((gnuplot . t)
                                (shell . t)
				(java . t)
				(latex . t)
				(makefile . t)
				(matlab . t)
				(octave . t)
                                (C . t)
                                (emacs-lisp . t)
                                (python . t)))



;; Load default header arguments for all languages
(add-to-list 'org-babel-default-header-args
             '(:noweb . "yes"))



;; Personalized settings for matlab in org-babel
(setq org-babel-default-header-args:matlab
  '((:exports . "results")(:results . "output")(:session . "*MATLAB*")))



;; org-agenda-settings
;; Copy-pasted from https://www.rousette.org.uk/archives/doom-emacs-tweaks-org-journal-and-org-super-agenda/
(use-package! org-super-agenda
  :after org-agenda
  :init
  (setq org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-include-deadlines t
      org-agenda-block-separator nil
      org-agenda-compact-blocks t
      org-agenda-start-day nil ;; i.e. today
      org-agenda-span 1
      org-agenda-start-on-weekday nil)
  (setq org-agenda-custom-commands
        '(("c" "Super view"
           ((agenda "" ((org-agenda-overriding-header "")
                        (org-super-agenda-groups
                         '((:name "Today"
                                  :time-grid t
                                  :date today
                                  :order 1)))))
            (alltodo "" ((org-agenda-overriding-header "")
                         (org-super-agenda-groups
                          '((:log t)
                            (:name "To refile"
                                   :file-path "refile\\.org")
                            (:name "Next to do"
                                   :todo "NEXT"
                                   :order 1)
                            (:name "Important"
                                   :priority "A"
                                   :order 6)
                            (:name "Today's tasks"
                                   :file-path "journal/")
                            (:name "Due Today"
                                   :deadline today
                                   :order 2)
                            (:name "Scheduled Soon"
                                   :scheduled future
                                   :order 8)
                            (:name "Overdue"
                                   :deadline past
                                   :order 7)
                            (:name "Meetings"
                                   :and (:todo "MEET" :scheduled future)
                                   :order 10)
                            (:discard (:not (:todo "TODO")))))))))))
  :config
  (org-super-agenda-mode))


;; elpy settings
(use-package! elpy
  :init
  (elpy-enable))



;; outline-minor mode settings
;;
;; Outline mode is a major mode derived from Text mode, which is
;; specialized for editing outlines. It provides commands to
;; navigate between entries in the outline structure, and commands
;; to make parts of a buffer temporarily invisible, so that the
;; outline structure may be more easily viewed.
;; Outline minor mode is a buffer-local minor mode which provides
;; the same commands as the major mode
(defun turn-on-outline-minor-mode ()
(outline-minor-mode 1))

;; (add-hook 'LaTeX-mode-hook 'turn-on-outline-minor-mode)
;; (add-hook 'latex-mode-hook 'turn-on-outline-minor-mode)
(add-hook 'LaTeX-mode-hook 'prettify-symbols-mode)
(setq outline-minor-mode-prefix "\C-c \C-o") ; Or something else



;; ;; wolfram-mode
;; (autoload 'wolfram-mode "wolfram-mode" nil t)
;; (autoload 'run-wolfram "wolfram-mode" nil t)
;; (setq wolfram-program "/Applications/Mathematica.app/Contents/MacOS/MathKernel")
;; (add-to-list 'auto-mode-alist '("\.m$" . wolfram-mode))
;; (setq wolfram-path "~/Library/Mathematica/Applications") ;; e.g. on Linux ~/.Mathematica/Applications

;; ;; Load mathematica from contrib
;; (org-babel-do-load-languages 'org-babel-load-languages
;; (append org-babel-load-languages                                       '((mathematica . t))))
;; ;; Sanitize output and deal with paths
;; ;; AN IMPORTANT NOTE REGARDING mash.pl is that you should use sudo chmod 755 ~/.local/bin/mash.pl first!!!!
;; (setq org-babel-mathematica-command "/usr/local/bin/mash.pl")
;; ;; Font-locking
;; (add-to-list 'org-src-lang-modes '("mathematica" . wolfram))
;; ;; For wolfram-mode
;; (setq mathematica-command-line "/usr/local/bin/mash.pl")



;; sage-shell-mode settings
;; Run SageMath by M-x run-sage instead of M-x sage-shell:run-sage
(sage-shell:define-alias)

;; Turn on eldoc-mode in Sage terminal and in Sage source files
(add-hook 'sage-shell-mode-hook #'eldoc-mode)
(add-hook 'sage-shell:sage-mode-hook #'eldoc-mode)

;; ob-sagemath settings
;; Ob-sagemath supports only evaluating with a session.
(setq org-babel-default-header-args:sage '((:session . t)
                                           (:results . "output")))

;; C-c c for asynchronous evaluating (only for SageMath code blocks).
(with-eval-after-load "org"
  (define-key org-mode-map (kbd "C-c c") 'ob-sagemath-execute-async))



;; laas-mode settings (Always before the QoL Mods)
(use-package! laas
  :hook (LaTeX-mode . laas-mode)
  :hook (org-mode . laas-mode)
  :config ; do whatever here
  (aas-set-snippets 'laas-mode
                    ;;expand unconditionally
                    ;;
                    ;; The following are crucial org-mode code block snippets. Update when necessary!
                    ;;
                    ;; LaTeX
                    "ltx" (lambda () (interactive) (yas-expand-snippet "#+begin_src latex\n$0\n#+end_src"))

                    ;; Mathematica
                    "mthm" (lambda () (interactive) (yas-expand-snippet "#+begin_src mathematica :results ${1:output} :exports ${2:both}\n$0\n#+end_src"))

                    ;; MATLAB
                    "mtlb" (lambda () (interactive) (yas-expand-snippet "#+begin_src matlab :exports ${1:both}\n$0\n#+end_src"))

                    ;; pandas session
                    "pypds" (lambda () (interactive) (yas-expand-snippet "#+begin_src python :session ${1:name} :results value :return ${2:RETURN_VARIABLE} :exports ${3:both}\n$0\n#+end_src"))

                    ;; pandas session tabulate
                    "pypdt" (lambda () (interactive) (yas-expand-snippet "#+begin_src python :session ${1:name} :results value raw :output :return tabulate(${2:name_of_the_data_frame}, headers=${3:name_of_the_data_frame}.columns, tablefmt='orgtbl')\n$0\n#+end_src"))

                    ;; python block with figures
                    "pwf" (lambda () (interactive) (yas-expand-snippet "#+begin_src python :results output file :file ${1:filename}.png :output-dir images/ :exports ${2:type}\n$0\n#+end_src"))

                    ;; python session
                    "pys" (lambda () (interactive) (yas-expand-snippet "#+begin_src python :session ${1:session_name} :results ${2:output} :exports ${3:both}\n$0\n#+end_src"))

                    ;; sage block
                    "sgb" (lambda () (interactive) (yas-expand-snippet "#+begin_src sage :results ${1:output} :exports ${2:both}\n$0\n#+end_src"))

                    ;; sage session
                    "sgs" (lambda () (interactive) (yas-expand-snippet "#+begin_src sage :session ${1:session_name} :results ${2:output} :exports ${3:both}\n$0\n#+end_src"))

                    ;; tht -> that
                    "tht" (lambda () (interactive) (yas-expand-snippet "that"))

                    ;; wht -> what
                    "wht" (lambda () (interactive) (yas-expand-snippet "what"))



                    ;;
                    ;; The following are crucial latex environment snippets. Update when necessary!
                    ;;

                    "mk" (lambda () (interactive) (yas-expand-snippet "\$$0\$"))

                    "dm" (lambda () (interactive) (yas-expand-snippet "\n\\[\n    $0\n\\]\n"))

                    "dtl" (lambda () (interactive) (yas-expand-snippet "\n\\[\n\\tag{${1:number}} \\label{eq:$1}\n    $0\n\\]\n"))

                    ;;
                    ;; align*
                    "alis" (lambda () (interactive) (yas-expand-snippet "\n\\begin{align*}\n  $0\n\\end{align*}\n"))

                    ;; align
                    "aln" (lambda () (interactive) (yas-expand-snippet "\n\\begin{align}\n  \\label{${1:eq$2}}\n  $0\n\\end{align}\n"))

                    ;; arrowlist
                    "arw" (lambda () (interactive) (yas-expand-snippet "\n\\begin{arrowlist}\n    \\item $0\n\\end{arrowlist}\n"))

                    ;; corollary
                    "crl" (lambda () (interactive) (yas-expand-snippet "\n\\begin{corollary}{ $1}\n  $0\n\\end{corollary}\n"))

                    ;; draw full line
                    "dfl" (lambda () (interactive) (yas-expand-snippet "\\noindent\\rule{\\textwidth}{.4pt} $0")) ;; Something's wrong?

                    ;; flashcard
                    "flc" (lambda () (interactive) (yas-expand-snippet "\n\\begin{flashcard}{ $1}\n  $0\n\\end{flashcard}\n"))

                    ;; definition
                    "dfn" (lambda () (interactive) (yas-expand-snippet "\n\\begin{definition}[ $1]\n  $0\n\\end{definition}\n"))

                    ;; enumerate (roman)
                    "enumr" (lambda () (interactive) (yas-expand-snippet "\n\\begin{enumerate}[label=(\\roman*)]\n  \\item $0\n\\end{enumerate}\n"))

                    ;; enumerate (alphanumerically)
                    "enuma" (lambda () (interactive) (yas-expand-snippet "\n\\begin{enumerate}[label=\\bfseries{(\\alph*)}]\n  \\item $0\n\\end{enumerate}\n"))

                    ;; enumerate (arabic)
                    "enump" (lambda () (interactive) (yas-expand-snippet "\n\\begin{enumerate}[label=(\\arabic*)]\n  \\item $0\n\\end{enumerate}\n"))

                    ;; equation
                    "eqn" (lambda () (interactive) (yas-expand-snippet "\n\\begin{equation}\n  \\label{${1:eq$2}}\n  $0\n\\end{equation}\n"))

                    ;; equation*
                    "eqs" (lambda () (interactive) (yas-expand-snippet "\n\\begin{equation*}\n  $0\n\\end{equation*}\n"))

                    ;; figure_wo_captions
                    "fg" (lambda () (interactive) (yas-expand-snippet "\n\\begin{figure}[ht]\n  \\centering \\includegraphics[scale=${1:0.40}]{${2:./images/${3:figname.png}}}\n\\end{figure}\n$0\n"))

                    ;; insert code
                    "icd" (lambda () (interactive) (yas-expand-snippet "\n\\begin{lstlisting}[numbers = ${2:left}, frame = ${3:single}, mathescape, language = $1]\n  $0\n\\end{lstlisting}\n"))

                    ;; custom mdframed block
                    "mdf" (lambda () (interactive) (yas-expand-snippet "\n\\begin{mdframed}[frametitle={${1:title}}, backgroundcolor=${2:gray!20}, frametitlebackgroundcolor=${3:green!20}]\n  $0
\\end{mdframed}\n"))



                    ;; set condition!
                    :cond #'texmathp ; expand only while in math
                    "supp" "\\supp"
                    "On" "O(n)"
                    "O1" "O(1)"
                    "Olog" "O(\\log n)"
                    "Olon" "O(n \\log n)"
                    ;; bind to functions!
                    ;;
                    ;; LATEX SNIPPETS
                    ;;
                    ;; BA: Better Accent?
                    ;;
                    ;;
                    ;; Left bracket
                    "lrb" (lambda () (interactive)
                            (yas-expand-snippet "\\left[ $1 \\right]$0"))

                    ;; Right bracket
                    "rbb" (lambda () (interactive)
                            (yas-expand-snippet "\\right]"))

                    ;; Left paranthesis
                    "lrp" (lambda () (interactive)
                            (yas-expand-snippet "\\left( $1 \\right)$0"))

                    ;; Right paranthesis
                    "rpp" (lambda () (interactive)
                            (yas-expand-snippet "\\right)"))

                    ;; indefinite integral
                    "intt" (lambda () (interactive)
                            (yas-expand-snippet "\\int $0"))

                    ;; Annihilation Operator - BA?
                    "anop" (lambda () (interactive)
                            (yas-expand-snippet "a^{\\dagger}_{\\vb{ $1}}$0"))

                    ;; Anticommutator - BA?
                    "acmt" (lambda () (interactive)
                            (yas-expand-snippet "\\acomm{${1:A}}{${2:B}}$0"))

                    ;; Christoffel Symbol - BA?
                    "cs" (lambda () (interactive)
                            (yas-expand-snippet "\\Gamma^{ ${1:\\rho}}_{{ ${2:\\mu}}{ ${3:\\nu}}}$0"))

                    ;; Commutator - BA?
                    "cmt" (lambda () (interactive)
                            (yas-expand-snippet "\\comm{${1:A}}{${2:B}}$0"))

                    ;; Creation Operator - BA?
                    "cro" (lambda () (interactive)
                            (yas-expand-snippet "a_{\\vb{ $1}}$0"))

                    ;; Evaluate in Bracket - BA?
                    "evtb" (lambda () (interactive)
                            (yas-expand-snippet "\\eval\[${1:x}|_{${2:0}}^{${3:\\infty}} $0"))

                    ;; Fourier Normalization Constant
                    "fnc" (lambda () (interactive)
                            (yas-expand-snippet "\\frac{1}{\\sqrt{2\\pi \\hbar}} $0"))

                    ;; Lorentz Invariant Measure - BA?
                    "lmes" (lambda () (interactive)
                            (yas-expand-snippet "\\int \\frac{d^3 ${1:p}}{(2\\pi)^3} \\frac{$3}{2\\omega_{\\vb{${2:p}}}}$0"))

                    ;; Momentum Space Measure
                    "msmes" (lambda () (interactive)
                            (yas-expand-snippet "\\int \\frac{d^3 ${1:p}}{(2\pi)^3}$0"))

                    ;; Position Space Measure
                    "posmes" (lambda () (interactive)
                            (yas-expand-snippet "\\int d^3 ${1:x}$0"))

                    ;; Dagger - NOT WORKING???
                    "dgr" (lambda () (interactive)
                            (yas-expand-snippet "{${1:a}}^{\\dagger}$0"))

                    ;; evaluate
                    "evt" (lambda () (interactive)
                            (yas-expand-snippet "\\eval{${1:x}}_{${2:0}}^{${3:\\infty}} $0"))

                    ;; htt02
                    "htt02" (lambda () (interactive)
                              (yas-expand-snippet "h^{TT}_{ $1} $0"))

                    ;; htt20
                    "htt20" (lambda () (interactive)
                              (yas-expand-snippet "h_{TT}^{ $1} $0"))

                    ;; ;; httmat (SOMETHING's WRONG!)
                    ;; "httmat" (lambda () (interactive)
                    ;;           (yas-expand-snippet "h^{TT}_{\\mu \\nu} =  \\mqty(\\zmat{1}{4} \\  \\mqty{0 \\ 0 \\ 0} &&\\mqty{\\dmat{,2\\tensor{s}{_{i}_{j}}, }}) $0"))

                    ;; infint
                    "infint" (lambda () (interactive)
                               (yas-expand-snippet "\\int_{- \\infty}^{\\infty} $0"))

                    ;; differentiate once
                    "dff" (lambda () (interactive)
                            (yas-expand-snippet "\\frac{d $2}{d $1}$0"))

                    ;; differentiate twice
                    "df2" (lambda () (interactive)
                            (yas-expand-snippet "\\frac{d^2 $2}{d $1 ^2}$0"))

                    ;; partial once
                    "pdf" (lambda () (interactive)
                            (yas-expand-snippet "\\frac{\\partial $2}{\\partial $1}$0"))

                    ;; partial twice
                    "pdd" (lambda () (interactive)
                            (yas-expand-snippet "\\frac{\\partial ^2 $2}{\\partial $1 ^2}$0"))

                    ;; product symbol
                    "pp" (lambda () (interactive)
                           (yas-expand-snippet "\\prod_{${1:i}} $0"))

                    ;; f(x,t)
                    "fxt" (lambda () (interactive)
                            (yas-expand-snippet "${1:f}(${2:x}, ${3:t})$0"))

                    ;; bra
                    "br" (lambda () (interactive)
                           (yas-expand-snippet "\\bra*{${1:q'',t''}}$0"))

                    ;; qm braket
                    "bk" (lambda () (interactive)
                            (yas-expand-snippet "\\braket*{${1:q'', t''}}{${2:q', t'}}$0"))

                    ;; qm ev
                    "exv" (lambda () (interactive)
                            (yas-expand-snippet "\\ev*{${1:operator}}{${2:states}}$0"))

                    ;; qm ket
                    "kt" (lambda () (interactive)
                           (yas-expand-snippet "\\ket*{${1:q', t'}}$0"))

                    ;; qm ketbra
                    "kbr" (lambda () (interactive)
                            (yas-expand-snippet "\\ketbra*{ $1}{ $2}$0"))

                    ;; qm matrix element
                    "qmel" (lambda () (interactive)
                             (yas-expand-snippet "\\mel*{${1:q'', t''}}{${3:e^{-iH(t''-t')}}}{${2:q', t'}}$0"))

                    ;; cross-reference
                    "rfr" (lambda () (interactive)
                            (yas-expand-snippet "\\ref{${1:eq:}${2:1}}$3} $0"))

                    ;; second derivative
                    "d2" (lambda () (interactive)
                           (yas-expand-snippet "\\frac{d^2 $2}{d$1 ^2}$0"))

                    ;; Sum
                    "smi" (lambda () (interactive)
                            (yas-expand-snippet "\\sum_{ $1 }$0"))

                    ;; sum_iton
                    "smn" (lambda () (interactive)
                           (yas-expand-snippet "\\sum_{${1:i} = ${2:0}}^{${3:\\infty}}$0"))

                    ;; sum_ntoinf
                    "snf" (lambda () (interactive)
                             (yas-expand-snippet "\\sum_{$1 = $2}^{\\infty}$0"))

                    ;; Span
                    "Span" (lambda () (interactive)
                             (yas-expand-snippet "\\Span( $1 )$0"))

                    ;; sum_substack
                    "sstack" (lambda () (interactive)
                               (yas-expand-snippet "\\sum_{\\substack{ $1}}$0"))

                    ;; cancel to something
                    "c2" (lambda() (interactive)
                            (yas-expand-snippet "\\cancelto{ ${1:0} }{ $2 }$0"))

                    ;; tensor_01
                    "tt01" (lambda () (interactive)
                            (yas-expand-snippet "\\tensor{ ${1:A}}{_{ ${2:\\mu}}}$0"))

                    ;; tensor_02
                    "tt02" (lambda () (interactive)
                            (yas-expand-snippet "\\tensor{ ${1:g}}{_{ ${2:\\mu}}_{ ${3:\\nu}}}$0"))

                    ;; tensor_03
                    "tt03" (lambda () (interactive)
                            (yas-expand-snippet "\\tensor{ $1}{_{ ${2:i}}_{ ${3:j}}_{ ${4:k}}}$0"))

                    ;; tensor_04
                    "tt04" (lambda () (interactive)
                            (yas-expand-snippet "\\tensor{ ${1:R}}{_{ ${2:\\rho}}_{ ${3:\\sigma}}_{ ${4:\\mu}}_{ ${5:\\nu}}}$0"))

                    ;; tensor_10
                    "tt10" (lambda () (interactive)
                            (yas-expand-snippet "\\tensor{ ${1:dx}}{^{ ${2:\\mu}}}$0"))

                    ;; tensor_11
                    "tt11" (lambda () (interactive)
                            (yas-expand-snippet "\\tensor{ ${1:T}}{^{ ${2:\\mu}}_{ ${3:\\nu}}}$0"))

                    ;; tensor_12
                    "tt12" (lambda () (interactive)
                            (yas-expand-snippet "\\tensor{ ${1:\\delta \\Sigma}}{^{ ${2:\\rho}}_{ ${3:\\mu}}_{ ${4:\\nu}}}$0"))

                    ;; tensor_13
                    "tt13" (lambda () (interactive)
                            (yas-expand-snippet "\\tensor{ ${1:R}}{^{ ${2:\\rho}}_{ ${3:\\sigma}}_{ ${4:\\mu}}_{ ${5:\\nu}}}$0"))

                    ;; tensor_20
                    "tt20" (lambda () (interactive)
                            (yas-expand-snippet "\\tensor{ ${1:T}}{^{ ${2:\\mu}}^{ ${3:\\nu}}}$0"))


                    ;; Add accent snippets
                    :cond #'laas-object-on-left-condition

                    ;; Slashed
                    "sss" (lambda () (interactive) (laas-wrap-previous-object "slashed"))

                    ;; Square Root
                    "qq" (lambda () (interactive) (laas-wrap-previous-object "sqrt"))

                    ;; Vector Arrow
                    "vnn" (lambda () (interactive) (laas-wrap-previous-object "va"))

                    ;; Vector Unit
                    "vu" (lambda () (interactive) (laas-wrap-previous-object "vu"))

                    ;; Vector Bold
                    "vv" (lambda () (interactive) (laas-wrap-previous-object "vb"))

                    ;; Absolute Value
                    "abv" (lambda () (interactive) (laas-wrap-previous-object "abs"))

                    ;; mathbb
                    "'g" (lambda () (interactive) (laas-wrap-previous-object "mathbb"))

                    ;; cancel
                    "cc" (lambda () (interactive) (laas-wrap-previous-object "cancel"))
                    ))







;; QoL Modifications (Always at the Bottom!)
;;
;;
;;
;; always recreate the *scratch* buffer
(defun prepare-scratch-for-kill ()
  (save-excursion
    (set-buffer (get-buffer-create "*scratch*"))
    (add-hook 'kill-buffer-query-functions 'kill-scratch-buffer
              t)))
(defun kill-scratch-buffer ()
  (let (kill-buffer-query-functions)
    (kill-buffer (current-buffer)))
  (prepare-scratch-for-kill)
  nil)

(prepare-scratch-for-kill)



;; always kill current buffer
(global-set-key (kbd "C-x k") 'kill-this-buffer)



;; switch-window settings
(use-package! switch-window
  :config
  (setq switch-window-init-style 'minibuffer)
  (setq switch-window-increase 4)
  (setq switch-window-threshold 2)
  (setq switch-window-shortcut-style 'qwerty)
  (setq switch-window-qwerty-shortcut
        '("a" "s" "d" "f" "h" "j" "k" "l"))
  :bind
  ([remap other-window] . switch-window))



;; split-and-follow
(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)



;; enable org-support-shift-select permanently
(setq org-support-shift-select 'always)



;; set truncate nils property to zero by default so that you can read long lines of code
(setq-default truncate-lines nil)



;; Do not confirm before evaluation
(setq org-confirm-babel-evaluate nil)



;; Show images when opening a file.
(setq org-startup-with-inline-images t)



;; Show images after evaluating code blocks.
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images)













;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;                                                              ;;;;;
;;;;; PURGATORY - This is where once-useful configs come to die.   ;;;;;
;;;;;                                                              ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Yasnippet configurations
;; (use-package! yasnippet
;;   :config
;;   (use-package! yasnippet-snippets)
;;   (yas-reload-all))

;; (require 'yasnippet)
;; (yas-global-mode 1)

;; ;; elpy configurations
;; (use-package! elpy
;;   :init
;;   (elpy-enable))

;; ;; yasnippet in org-mode
;; (add-hook 'org-mode-hook
;;           (lambda()
;;             (setq-local yas/trigger-key [tab])
;;             (define-key yas/keymap [tab]
;;               'yas/next-field-or-maybe-expand)))



;; ;; auctex-latexmk setup and settings (THERE ARE ISSUES COME BACK LATER)

;; (use-package! auctex-latexmk
;;   :init
;;   (with-eval-after-load 'tex
;;     (auctex-latexmk-setup))
;;   :config
;;   ;; Use latexmk as the default command.
;;   ;; (We have to use a hook instead of 'setq-default' because
;;   ;; AUCTEX sets this variable on mode activation.)
;;   (defun my-tex-set-latexmk-as-default ()
;;     (setq TeX-command-default "LatexMk"))
;;   (add-hook 'TeX-mode-hook #'my-tex-set-latexmk-as-default)
;;   ;; Compile to PDF when 'TeX-PDF-mode' is active.
;;   (setq auctex-latexmk-inherit-TeX-PDF-mode t))
