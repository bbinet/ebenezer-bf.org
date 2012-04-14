
PELICAN=pelican
PELICANOPTS=None

BASEDIR=$(PWD)
INPUTDIR=$(BASEDIR)/
OUTPUTDIR=$(BASEDIR)/_output
CONFFILE=$(BASEDIR)/pelican.conf.py

FTP_HOST=localhost
FTP_USER=anonymous
FTP_TARGET_DIR=/

SSH_HOST=srvb
SSH_USER=data
SSH_TARGET_DIR=/home/data/websites/static/ebenezer-bf.org

DROPBOX_DIR=~/Dropbox/Public/

LIB_DIR=$(BASEDIR)/theme/lib
BS_SRCDIR=$(LIB_DIR)/bootstrap
BS_DSTDIR=$(OUTPUTDIR)/theme/bootstrap
LESSC=$(BASEDIR)/less.js/bin/lessc


help:
	@echo 'Makefile for a pelican Web site                                       '
	@echo '                                                                      '
	@echo 'Usage:                                                                '
	@echo '   make html                        (re)generate the web site         '
	@echo '   make clean                       remove the generated files        '
	@echo '   ftp_upload                       upload the web site using FTP     '
	@echo '   ssh_upload                       upload the web site using SSH     '
	@echo '   dropbox_upload                   upload the web site using Dropbox '
	@echo '                                                                      '

bootstrap:
	mkdir -p $(BS_DSTDIR)/img
	mkdir -p $(BS_DSTDIR)/css
	mkdir -p $(BS_DSTDIR)/js
	cp $(BS_SRCDIR)/img/* $(BS_DSTDIR)/img/
	$(LESSC) --compress $(LIB_DIR)/swatchmaker.less $(BS_DSTDIR)/css/bootstrap.min.css
	cp $(BS_SRCDIR)/js/bootstrap-dropdown.js $(BS_DSTDIR)/js/
	cp $(BS_SRCDIR)/js/bootstrap-collapse.js $(BS_DSTDIR)/js/
	@echo 'Done'

html: clean $(OUTPUTDIR)/index.html bootstrap
	@echo 'Done'

$(OUTPUTDIR)/%.html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE)

clean:
	rm -fr $(OUTPUTDIR)
	mkdir $(OUTPUTDIR)

dropbox_upload: $(OUTPUTDIR)/index.html
	cp -r $(OUTPUTDIR)/* $(DROPBOX_DIR)

ssh_upload: $(OUTPUTDIR)/index.html
	rsync -Cavz -e ssh --delete $(OUTPUTDIR)/* $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR)

ftp_upload: $(OUTPUTDIR)/index.html
	lftp ftp://$(FTP_USER)@$(FTP_HOST) -e "mirror -R $(OUTPUT_DIR)/* $(FTP_TARGET_DIR) ; quit"

github: $(OUTPUTDIR)/index.html
	ghp-import $(OUTPUTDIR)
	git push origin gh-pages

.PHONY: html help clean ftp_upload ssh_upload dropbox_upload github
    
