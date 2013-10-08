#
# File:		Makefile.am
# Project:	XEmacsUtils
# Desc:
#
#   Build rules and targets
#
# Author(s):   Paul Houghton <paul4hough@gmail.com>
# Created:     05/16/2003 04:03
#

hide = @

ELISP_SOURCES	= $(wildcard *.el);

INSTALL_DIR	= $(HOME)/.xemacs

$(INSTALL_DIR):
	mkdir $@

$(INSTALL_DIR)/%.el : %.el
	$(hide) [ ! -f "$@" ] || mv "$@" "$@.`date +%F-%H%M%S`.bak"
	$(hide) install -p -c -m 444 "$^" "$@"
	@echo "+ Installed $@"

install-data-hook: $(INSTALL_DIR) $(ELISP_SOURCES:%=$(INSTALL_DIR)/%)
