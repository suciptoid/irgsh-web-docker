FROM debian:jessie-slim

# Pasang dependensi yang diperlukan
RUN apt-get update && apt-get install -y -qq make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils sudo \
python python-pip python-dev python-debian dpkg-dev rabbitmq-server git-core nginx libpq-dev git vim net-tools

# Konfigurasi .bashrc untuk bisa memanggil pyenv dari bash
RUN curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash &&\
	/bin/bash -c "echo 'export PATH=\"~/.pyenv/bin:${PATH}\"' >> ${HOME}/.bashrc" &&\
	/bin/bash -c "echo 'eval \"\$(pyenv init -)\"' >> ${HOME}/.bashrc" &&\
	/bin/bash -c "echo 'eval \"\$(pyenv virtualenv-init -)\"' >> ${HOME}/.bashrc" &&\
	/bin/bash -c "source ${HOME}/.bashrc" &&\ 
	pyenv install 2.6.6 &&\
	pyenv shell 2.6.6 &&\
	mkdir ~/src/

WORKDIR ~/src/

RUN git clone git://github.com/BlankOn/python-irgsh.git &&\
	git clone git://github.com/BlankOn/irgsh-web.git && \
	git clone git://github.com/BlankOn/irgsh-node.git && \
	git clone git://github.com/BlankOn/irgsh-repo.git

WORKDIR ~/src/irgsh-web/

RUN ln -s ../python-irgsh/irgsh && \
	ln -s ../irgsh-node/irgsh_node && \
	ln -s ../irgsh-repo/irgsh_repo

# Buat berkas yang dibutuhkan dengan bootstrap.py
RUN ["python","bootstrap.py"]

# Small Hack
RUN pyenv shell 2.6.6 &&\
	sed -i 's/(MARKER_EXPR())/(MARKER_EXPR)/' ~/.pyenv/versions/2.6.6/lib/python2.6/site-packages/packaging/requirements.py &&\
	rm -rf eggs/pyparsing* &&\
	pip uninstall pyparsing -y &&\
	pip install pyparsing &&\
	pip install pyparsing==1.5.7 || echo "Pyparsing Try 1 fails" &&\
	pip install pyparsing==1.5.7 || echo "Pyparsing Try 2 fails" &&\
	pip install -r requirements.txt &&\
	./bin/buildout

# Expose Port
EXPOSE 8080

CMD ["pyenv", "shell", "2.6.6"]
CMD ["python", "manage.py", "runfcgi", "method=prefork", "host=0.0.0.0", "port=8080"]

