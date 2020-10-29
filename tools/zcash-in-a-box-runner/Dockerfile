FROM electriccoinco/zcashd-build:debian10

RUN apt-get update && \
    apt-get install -y \
      jq zip

ARG GO_IPFS_VERSION=v0.6.0
ARG RCLONE_VERSION=v1.51.0
RUN curl -LO https://dist.ipfs.io/go-ipfs/${GO_IPFS_VERSION}/go-ipfs_${GO_IPFS_VERSION}_linux-amd64.tar.gz \
    && tar zxf go-ipfs_${GO_IPFS_VERSION}_linux-amd64.tar.gz \
    && cp go-ipfs/ipfs /usr/local/bin/ipfs \
    && rm -Rf go-ipfs_$GO_IPFS_VERSION_linux-amd64.tar.gz \
    && curl -L https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc \
    && curl -LO https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.zip \
    && unzip rclone-${RCLONE_VERSION}-linux-amd64.zip \
    && cp rclone-${RCLONE_VERSION}-linux-amd64/rclone /usr/local/bin/rclone \
    && chmod +x /usr/local/bin/rclone \
    && rm rclone-${RCLONE_VERSION}-linux-amd64.zip
RUN curl -LO https://github.com/tektoncd/cli/releases/download/v0.12.1/tkn_0.12.1_Linux_x86_64.tar.gz \
    && tar xvzf tkn_0.12.1_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
# Kubectl
RUN curl -L "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl
# yq
ARG YQ_VERSION=3.4.1
RUN curl -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 \
    -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq