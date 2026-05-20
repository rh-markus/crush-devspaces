FROM registry.access.redhat.com/ubi9/ubi:latest

# Set up environment
ENV HOME=/home/user \
    WORKDIR=/projects \
    CRUSH_DISABLE_METRICS=true \
    TERM=xterm-256color

# Create user home directory with proper permissions for OpenShift
RUN mkdir -p ${HOME}/.local/share/crush ${HOME}/.config/crush ${WORKDIR} && \
    chmod -R g=u ${HOME} ${WORKDIR} /etc/passwd /etc/group

# Add Charm repository
RUN printf '[charm]\n\
name=Charm\n\
baseurl=https://repo.charm.sh/yum/\n\
enabled=1\n\
gpgcheck=1\n\
gpgkey=https://repo.charm.sh/yum/gpg.key\n' > /etc/yum.repos.d/charm.repo

# Install Crush and dependencies
RUN dnf install -y --nodocs \
    crush \
    git-core \
    vim-minimal \
    procps-ng \
    findutils \
    which \
    && dnf clean all

# Copy default Crush configuration if provided
COPY --chown=1001:0 crush.json ${HOME}/.config/crush/crush.json

# Ensure proper permissions for arbitrary UIDs (OpenShift requirement)
RUN chmod -R g=u ${HOME} ${WORKDIR}

WORKDIR ${WORKDIR}

# OpenShift runs containers with arbitrary UIDs, so we need a flexible user setup
USER 1001

# Keep container running (DevSpaces manages the lifecycle)
CMD ["tail", "-f", "/dev/null"]
