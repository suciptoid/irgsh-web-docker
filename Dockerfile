FROM debian:stable-slim

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
	/bin/bash -c "source ${HOME}/.bashrc"

#RUN ["ln", "-s", "${HOME}/.pyenv/bin/pyenv", "/usr/bin/pyenv"] # tidak perlu ini

# Pasang Python 2.6.6 kemudian pakai shell pyenv 2.6.6 
RUN /bin/bash -c "/root/.pyenv/bin/pyenv install 2.6.6"
#RUN bash -c /root/.pyenv/bin/pyenv shell 2.6.6 # terjadi galat
#RUN ["pyenv","shell","2.6.6"] # terjadi galat pada container_linux.go disini

# Buat direktori $HOME/.bin/ untuk tautan penggunaan python2.6.6 nantinya
#RUN mkdir /root/.bin/
#RUN ["ln","-s", "/root/.pyenv/versoins/2.6.6/bin/python2.6", "/root/.bin/python"]
#RUN /bin/bash -c "echo 'export PATH=\"~/.bin:${PATH}\"' >> ${HOME}/.bashrc"
#RUN /bin/bash -c "source ${HOME}/.bashrc"
# Langkah di atas (bagian ini) mungkin bisa di lewati saja.

# Klon data dari repositori github
RUN mkdir /root/src/
WORKDIR /root/src/
RUN git clone git://github.com/BlankOn/python-irgsh.git &&\
	git clone git://github.com/BlankOn/irgsh-web.git && \
	git clone git://github.com/BlankOn/irgsh-node.git && \
	git clone git://github.com/BlankOn/irgsh-repo.git

WORKDIR irgsh-web
RUN ln -s ../python-irgsh/irgsh && \
	ln -s ../irgsh-node/irgsh_node && \
	ln -s ../irgsh-repo/irgsh_repo

# Buat berkas yang dibutuhkan dengan bootstrap.py
RUN ["/root/.pyenv/versions/2.6.6/bin/python2.6","bootstrap.py"]

# Sekedar testing untuk versi python-nya
CMD ["/bin/bash"]
# CMD ["/bin/bash","-c","/root/.pyenv/versions/2.6.6/bin/python2.6"]

