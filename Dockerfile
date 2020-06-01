FROM centos
RUN yum install httpd -y
COPY website/ /var/www/html/ 
RUN yum install php -y
EXPOSE 80
CMD /usr/sbin/httpd -DFOREGROUND

