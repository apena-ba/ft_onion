FROM debian:latest

RUN apt-get update -y && apt upgrade -y
RUN apt-get install nginx tor openssh-server sudo vim -y

COPY sshd_config /etc/ssh/sshd_config
COPY torrc /etc/tor/torrc
COPY index.html /var/www/html/index.html
COPY onion.gif /var/www/html/onion.gif
COPY config.conf /etc/nginx/nginx.conf

COPY service_init.sh .
RUN chmod +x service_init.sh

RUN useradd -m adri
RUN echo "adri:123456" | chpasswd

RUN sudo -u adri mkdir -p /home/adri/.ssh
RUN sudo -u adri chmod 700 /home/adri/.ssh
COPY --chown=adri temp_pub_key.pub /home/adri/.ssh/authorized_keys
RUN sudo -u adri chmod 600 /home/adri/.ssh/authorized_keys

RUN groupadd sshusers
RUN usermod -aG sshusers adri
RUN usermod -aG sudo adri

CMD ["sh", "service_init.sh"]