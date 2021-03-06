
PELICAN=./buildout/bin/pelican
GHP_IMPORT=./buildout/bin/ghp-import

BASEDIR=$(PWD)
INPUTDIR=$(BASEDIR)/
OUTPUTDIR=$(BASEDIR)/_output
CONFFILE=$(BASEDIR)/pelican.conf.py

SSH_HOST=srvb
SSH_USER=data
SSH_TARGET_DIR=/home/data/websites/static/ebenezer-bf.org


help:
	@echo ' Makefile for a pelican Web site                                   '
	@echo '                                                                   '
	@echo ' Usage:                                                            '
	@echo '    make html                        (re)generate the web site     '
	@echo '    make clean                       remove the generated files    '
	@echo '    ssh_upload                       upload the web site using SSH '
	@echo '    github                           upload the web site on github '
	@echo '                                                                   '

html: clean $(OUTPUTDIR)/index.html
	cp $(BASEDIR)/CNAME $(OUTPUTDIR)
	@echo 'Done'

$(OUTPUTDIR)/%.html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE)

clean:
	rm -fr $(OUTPUTDIR)
	mkdir $(OUTPUTDIR)

ssh_upload: $(OUTPUTDIR)/index.html
	rsync -Cavz -e ssh --delete $(OUTPUTDIR)/* $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR)

github: html
	$(GHP_IMPORT) $(OUTPUTDIR)
	git push origin gh-pages

.PHONY: html help clean ssh_upload github
    
