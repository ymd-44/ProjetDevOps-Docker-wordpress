# Choisissez une image Ubuntu légère
FROM ubuntu:latest

# Set environment variables to disable debconf prompts
ENV DEBIAN_FRONTEND=noninteractive

# Mettez à jour les paquets Ubuntu
RUN apt-get clean && apt-get update
RUN apt-get install -y --no-install-recommends tzdata

# Installez les paquets nécessaires
RUN apt-get install -y apache2
RUN apt-get install -y php libapache2-mod-php
RUN apt-get install -y php-mysql
RUN apt-get install -y wget unzip

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get upgrade -y

# Téléchargez, décompressez et installez WordPress
RUN wget https://wordpress.org/latest.zip && \
  unzip latest.zip && \
  mv wordpress /var/www/html/ && \
  chown -R www-data:www-data /var/www/html/wordpress
COPY conf/wp-config.php /var/www/html/wordpress/
RUN chmod -R 755 /var/www/html/wordpress

# Configurez Apache pour servir votre site WordPress
RUN echo '\n<Directory /var/www/html/wordpress/>\n\
    AllowOverride All\n\
</Directory>\n' >> /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Exposez le port 80 pour le serveur web
EXPOSE 80

# Lancez Apache en arrière-plan
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]