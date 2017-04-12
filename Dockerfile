FROM debian:jessie-slim

# Pasang dependensi yang diperlukan
RUN apt-get update && apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils sudo \
python python-pip python-dev python-debian dpkg-dev rabbitmq-server git-core nginx libpq-dev git vim

# Pasang pyenv untuk penggunaan Python 2.6.6 nantinya
RUN curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash

# Konfigurasi .bashrc untuk bisa memanggil pyenv dari bash
RUN /bin/bash -c "echo 'export PATH=\"~/.pyenv/bin:${PATH}\"' >> ${HOME}/.bashrc" &&\
	/bin/bash -c "echo 'eval \"\$(pyenv init -)\"' >> ${HOME}/.bashrc" &&\
	/bin/bash -c "echo 'eval \"\$(pyenv virtualenv-init -)\"' >> ${HOME}/.bashrc" &&\
	/bin/bash -c "source ${HOME}/.bashrc" && \ 
	/bin/bash -c "/root/.pyenv/bin/pyenv install 2.6.6"

# Klon data dari repositori github
RUN mkdir /root/src/
WORKDIR /root/src/
RUN git clone git://github.com/BlankOn/python-irgsh.git &&\
	git clone git://github.com/BlankOn/irgsh-web.git && \
	git clone git://github.com/BlankOn/irgsh-node.git && \
	git clone git://github.com/BlankOn/irgsh-repo.git

WORKDIR /root/src/irgsh-web/
RUN ln -s ../python-irgsh/irgsh && \
	ln -s ../irgsh-node/irgsh_node && \
	ln -s ../irgsh-repo/irgsh_repo

# Buat berkas yang dibutuhkan dengan bootstrap.py
RUN ["/root/.pyenv/versions/2.6.6/bin/python2.6","bootstrap.py"]

# Sekedar testing untuk versi python-nya
CMD ["/bin/bash"]
# CMD ["/bin/bash","-c","/root/.pyenv/versions/2.6.6/bin/python2.6"]

