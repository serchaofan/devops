FROM centos:7
RUN yum -y install  openssh-server
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N redhat 
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N redhat
RUN echo "redhat" | passwd root --stdin
RUN ssh-keygen -A
CMD ["/usr/sbin/sshd", "-D"]
EXPOSE 22
