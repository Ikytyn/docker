# Use the existing base image
FROM docker.io/openmicroscopy/omero-ssh-systemd
MAINTAINER nisp

# Install necessary packages
RUN yum install -y git vim telnet lsof 

# Clean YUM cache
RUN yum clean all 

# Install Java 11
RUN yum install -y java-11-openjdk-devel
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
# Fix missing file
RUN touch /usr/bin/locale-check && chmod 755 /usr/bin/locale-check

# Add users
RUN useradd -u 1001 efadmin
RUN useradd -u 1002 efnobody

# Update .bashrc for root
RUN echo "#\\n# local config \\n#" >> /root/.bashrc
RUN echo "alias l=\"ls -al\"" >> /root/.bashrc

# Set the JAVA_HOME environment variable for Java 11
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> /root/.bashrc
RUN echo "export PATH=$JAVA_HOME/bin:$PATH" >> /root/.bashrc

# Add EnginFrame and license files
ADD enginframe-2021.0-r1657.jar /enginframe-2021.0-r1657.jar
ADD license.ef /lic.ef
ADD efinstall.config /tmp/efinstall.config
ADD license.ef /tmp/license.ef
# Install EnginFrame using Java 11
RUN cd /tmp && java -jar /enginframe-2021.0-r1657.jar --batch

# Configure EF to use DCV SM and other configurations
ADD cluster.props /opt/nice/enginframe/conf/plugins/dcvsm/clusters.props
RUN chmod 600 /opt/nice/enginframe/conf/plugins/dcvsm/clusters.props && chown efnobody:efnobody /opt/nice/enginframe/conf/plugins/dcvsm/clusters.props
ADD grid.conf /opt/nice/enginframe/conf/plugins/grid/grid.conf

# Add network translations
ADD nat.conf /opt/nice/enginframe/conf/plugins/interactive/nat.conf

# Add additional configurations and files
ADD interactive_builtin_linux_desktop.xml /opt/nice/enginframe/data/plugins/vdi/services/published/interactive_builtin_linux_desktop.xml
ADD interactive_67b1146427784051af628d097a61a631.xml /opt/nice/enginframe/data/plugins/vdi/services/published/interactive_67b1146427784051af628d097a61a631.xml
ADD interactive_67b1146427784051af628d097a61a631.tgz /opt/nice/enginframe/data/plugins/vdi/services/catalog/
ADD interactive_builtin_windows_desktop.xml /opt/nice/enginframe/data/plugins/vdi/services/published/interactive_builtin_windows_desktop.xml

# Add setup script
ADD ef-setup.sh /setup.sh

# Set CMD
CMD [ "/setup.sh", "nobash" ]
