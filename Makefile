.ONESHELL:
SHELL := /bin/bash
PUBLIC := public

.PHONY: all
all: build

.PHONY: clean
clean:
	rm -rf $(PUBLIC)

.PHONY: server
server:
	hugo server

.PHONY: build
build:
	hugo --cleanDestinationDir

.PHONY: update
update:
	git submodule update --remote --merge

validate-create:
	@if [ -z `echo $(TITLE)|sed -E -e 's/[[:blank:]]+/-/g'` ]; then\
           echo "TITLE not set. Pass in TITLE=<title name>"; exit 10;\
    fi

.PHONY: new
new: validate-create ## Create a new post in posts folder
	{ \
	echo "== Creating new post";\
	output=$$(hugo new posts/`date -u +'%Y-%m-%d-'``echo $${TITLE}|sed -E -e 's/[[:blank:]]+/-/g'`.md 2>&1);\
    filename1=$$(echo "$$output"|awk '{print $$1}');\
    filename2=$$(echo "$$output"|awk '{print $$2}');\
    if [ -f "$$filename1" ]; then \
        filename="$$filename1";\
    elif [ -f "$$filename2" ]; then \
        filename="$$filename2";\
    else \
        echo "Something wrong";\
    fi;\
    typora "$$filename";\
	}

.PHONY: push
push: build
	git add .
	git commit -am$$(date +%F)
	git push
