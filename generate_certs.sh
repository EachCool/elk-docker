#!/bin/bash
set -e

# 创建证书目录
mkdir -p cert
cd cert

# 生成无密码 CA
docker run --rm -v $(pwd):/certs docker.elastic.co/elasticsearch/elasticsearch:9.1.2 \
  bin/elasticsearch-certutil ca --out /certs/elastic-ca.p12 --pass ""

# 创建 instances.yaml 自动生成多证书，增加真实IP，用“,”隔开
cat > instances.yml <<EOF
instances:
  - name: elasticsearch
    dns: [elasticsearch]
    ip: [127.0.0.1]
  - name: kibana
    dns: [kibana]
    ip: [127.0.0.1]
  - name: logstash
    dns: [logstash]
    ip: [127.0.0.1]
EOF

# 生成证书
docker run --rm -v $(pwd):/certs docker.elastic.co/elasticsearch/elasticsearch:9.1.2 \
  bin/elasticsearch-certutil cert --in /certs/instances.yml \
  --ca /certs/elastic-ca.p12 --ca-pass "" \
  --out /certs/elastic-certificates.zip

# 解压
unzip elastic-certificates.zip -d .
echo "证书生成完成，放在 cert/ 目录下"

