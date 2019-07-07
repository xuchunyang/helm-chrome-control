;;; helm-chrome-control.el --- Control Chrome tabs with Helm (macOS only)  -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Xu Chunyang

;; Author: Xu Chunyang
;; Homepage: https://github.com/xuchunyang/helm-chrome-control
;; Package-Requires: ((emacs "25.1") (helm-core "3.0"))
;; Created: 2019/7/7 清晨
;; Version: 1.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Control Chrome tabs with Helm.

;;; Code:

(require 'helm)
(require 'json)

(defconst helm-chrome-control-chrome.js
  (expand-file-name
   "chrome.js"
   (file-name-directory (or load-file-name buffer-file-name))))

(defun helm-chrome-control-list ()
  "List Chrome tabs."
  (with-temp-buffer
    ;; Is there any case when chrome.js is not executable?
    (call-process helm-chrome-control-chrome.js nil t nil "list")
    (goto-char (point-min))
    (let ((json-array-type 'list))
      (json-read))))

(defun helm-chrome-control-candidates ()
  "Build helm candidates."
  (mapcar
   (lambda (item)
     (let-alist item
       (cons (concat .title "\n" .url) item)))
   (alist-get 'items (helm-chrome-control-list))))

(defvar helm-chrome-control-actions
  (helm-make-actions
   "Focus Tab"
   (lambda (item)
     (call-process helm-chrome-control-chrome.js nil nil nil "focus" (let-alist item .arg)))
   "Close Tab"
   (lambda (item)
     (call-process helm-chrome-control-chrome.js nil nil nil "close" "--yes" (let-alist item .arg)))
   "Copy URL"
   (lambda (item)
     (let-alist item
       (kill-new .url)
       (message "URL copied: %s" .url)))
   "Copy title"
   (lambda (item)
     (let-alist item
       (kill-new .title)
       (message "Title copied: %s" .title)))
   "Open URL in EWW"
   (lambda (item)
     (eww (let-alist item .url))))
  "Actions for the command `helm-chrome-control'.")

;;;###autoload
(defun helm-chrome-control ()
  "Control Chrome tabs with Helm."
  (interactive)
  (helm
   :buffer "*helm chrome tabs*"
   :sources
   (helm-build-sync-source "Chrome Tabs"
     :candidates #'helm-chrome-control-candidates
     :action helm-chrome-control-actions
     :multiline t)))

(provide 'helm-chrome-control)
;;; helm-chrome-control.el ends here
