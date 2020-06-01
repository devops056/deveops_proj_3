FROM centos
RUN yum install httpd -y 
RUN yum install php -y
CMD /usr/sbin/httpd -DFOREGROUND
COPY website/ /var/www/html/
