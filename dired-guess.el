;;; dired-guess.el --- Launch programs from Dired based on extension. -*- lexical-binding: t -*-

;; Copyright (C) 2019 Oleh Krehel

;; Author: Oleh Krehel <ohwoeowho@gmail.com>
;; URL: https://github.com/abo-abo/dired-guess
;; Version: 0.1.0
;; Package-Requires: ((emacs "24.3"))
;; Keywords: programs, utility

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; The utility of this package is to automatically associate
;; extensions to programs that can open them.
;;
;;; Setup:
;;
;; (require 'dired-guess)
;; (define-key dired-mode-map "r" 'dig-start)

;;; Code:

;;* Functions
(require 'dired-x)

(defun dig-connect (exts &rest progs)
  "Connect a list EXTS to a list PROGS that can open them."
  (when (stringp exts)
    (setq exts (list exts)))
  (let ((re
         (concat
          "\\."
          (regexp-opt exts)
          "\\'")))
    (add-to-list
     'dired-guess-shell-alist-user
     `(,re ,@progs))))

;;;###autoload
(defun dig-start (cmd &optional file-list)
  "Run CMD on FILE-LIST using nohup."
  (interactive
   (let ((files (dired-get-marked-files t nil)))
     (list
      (if current-prefix-arg
          (dired-read-shell-command "& on %s: " nil files)
        (let ((prog (dired-guess-default files)))
          (if (consp prog)
              (car prog)
            prog)))
      files)))
  (start-process
   cmd nil shell-file-name
   shell-command-switch
   (format
    "nohup 1>/dev/null 2>/dev/null %s %s"
    cmd
    (mapconcat #'shell-quote-argument file-list " "))))

;;* Linting
(dig-connect
 '("xml" "xml.rels") '(format "xmllint --format %s --output %s" file file))
(dig-connect
 "json" "python -m json.tool > indented.json")
(dig-connect
 "py" "autopep8 -i")

;;* PDF-like
(dig-connect
 '("pdf" "djvu" "ps" "eps")
 "evince" "okular")

;;* Media
(dig-connect
 '("jpg" "jpeg" "png" "svg" "gif" "tiff" "xpm" "bmp")
 "eog")

(dig-connect
 '("mp4" "mkv" "mpg" "m4v" "avi" "flv" "ogv" "ifo" "wmv" "webm" "part")
 "vlc")

(dig-connect
 '("mp3" "flac" "wv")
 "rhythmbox")

(dig-connect "epub" "calibre")
(dig-connect "html" "firefox")

;;* Editing
(dig-connect "xcf" "gimp")
(dig-connect
 '("odt" "ods" "csv"
   "pptx" "emf" "xls" "xlsx" "xlsb" "xlsm" "doc" "docx")
 "libreoffice")
(dig-connect
 "tex"
 "pdflatex" "latex")
(dig-connect
 "cue" "audacious")

;;* Files
(dig-connect
 '("zip" "tgz" "tar.gz" "tar.xz")
 "file-roller")

(dig-connect
 "" "nautilus")

(provide 'dired-guess)

;;; dired-guess.el ends here
