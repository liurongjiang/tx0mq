PROJ := tx0mq
GOOGLE_REPO := code.google.com/p/$(PROJ)
GITHUB_REPO := github.com:oubiwann/$(PROJ).git
AUTHOR ?= oubiwann
MSG_FILE ?= MSG
LIB := $(PROJ)
VERSION := $(shell python $(LIB)/scripts/getVersion.py)


version:
	@echo $(VERSION)


clean:
	find ./ -name "*~" -exec rm {} \;
	find ./ -name "*.pyc" -exec rm {} \;
	find ./ -name "*.pyo" -exec rm {} \;
	find . -name "*.sw[op]" -exec rm {} \;
	rm -rf $(MSG_FILE).backup _trial_temp/ build/ dist/ MANIFEST \
		CHECK_THIS_BEFORE_UPLOAD.txt *.egg-info


push-tags:
	git push --tags git@$(GITHUB_REPO)
	git push --tags https://$(GOOGLE_REPO)


push:
	git push --all git@$(GITHUB_REPO)
	git push --all https://$(GOOGLE_REPO)


push-all: push push-tags


pull:
	git pull -a https://$(GITHUB_REPO)


update: pull push-all


delete-branch: BRANCH := XXX
delete-branch:
	git branch -D $(BRANCH)
	git push origin :$(BRANCH)


delete-tag: TAG := XXX
delete-tag:
	git tag -d $(TAG)
	git push origin :refs/tags/$(TAG)


commit-raw:
	git commit -a -v


msg:
	@rm -f $(MSG_FILE)
	@echo '!!! REMOVE THIS LINE !!!' >> $(MSG_FILE)
	@git diff ChangeLog |egrep -v '^\+\+\+'|egrep '^\+.*'|sed -e 's/^+//' >> $(MSG_FILE)


commit: msg
	git commit -a -v -t $(MSG_FILE)
	mv $(MSG_FILE) $(MSG_FILE).backup
	touch $(MSG_FILE)


commit-push: commit push-all


stat: msg
	@echo
	@echo "### Changes ###"
	@echo
	-@cat $(MSG_FILE)|egrep -v '^\!\!\!'
	@echo
	@echo "### Git working branch status ###"
	@echo
	@git status -s
	@echo
	@echo "### Git branches ###"
	@echo
	@git branch


status: stat


todo:
	git grep -n -i -2 XXX


build:
	@python setup.py build
	@python setup.py sdist


clean-virt: clean
	rm -rf $(VIRT_DIR)


check-dist:
	@echo "Need to fill this in ..."


check:
	/usr/bin/env pep8 --repeat --ignore=E501 tx0mq
	/usr/bin/env pyflakes tx0mq
	/usr/bin/env trial tx0mq


check-integration:
# placeholder for integration tests


build-docs:
	cd docs/sphinx; make html


register:
	python setup.py register


upload: check
	python setup.py sdist upload --show-response


upload-docs: build-docs
	python setup.py upload_docs --upload-dir=docs/html/


.PHONY: push-all update msg commit-push status todo check check-integration
