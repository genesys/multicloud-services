FROM summerwind/actions-runner:latest

# envsubst (gettext-base)
# yq
RUN sudo apt update -y \
  && sudo apt install -y gettext-base \
  && sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  && sudo chmod a+x /usr/local/bin/yq \
  && sudo rm -rf /var/lib/apt/lists/*

# oc cli (provides kubectl 1.21)
RUN cd /tmp && wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz \
	&& tar xvf oc.tar.gz \
	&& sudo mv oc kubectl /usr/local/bin/

# latest kubectl
RUN cd /tmp && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
	&& sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# helm 3.8.2
RUN cd /tmp && wget https://get.helm.sh/helm-v3.8.2-linux-amd64.tar.gz \
	&& tar xvf helm-*-linux-amd64.tar.gz \
	&& sudo mv linux-amd64/helm /usr/local/bin

# RUN echo "yq version:" && yq --version \
# 	&& echo "kubectl version:" && kubectl version --short \
# 	&& echo "oc version:" && oc version \
# 	&& echo "helm version:" && helm version \
# 	&& which envsubst \
# 	&& which openssl
