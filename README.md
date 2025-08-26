# elk-docker

# 1. 设置kibana_system密码（输入 KibanaTest@123）
docker exec -it elasticsearch bin/elasticsearch-reset-password -u kibana_system -i

# 2. 设置logstash_system密码（输入 LogstashTest@123）
docker exec -it elasticsearch bin/elasticsearch-reset-password -u logstash_system -i

1️⃣ 生成 CA（elastic-ca.p12）


# 生成 CA
docker run --rm -v $(pwd):/certs docker.elastic.co/elasticsearch/elasticsearch:9.1.2 \
  bin/elasticsearch-certutil ca \
  --out /certs/elastic-ca.p12 \
  --pass ""

2️⃣ 生成节点证书（elastic-certificates.p12）
支持多个服务（ES、Kibana、Logstash、Filebeat）：


docker run --rm -v $(pwd):/certs docker.elastic.co/elasticsearch/elasticsearch:9.1.2 \
  bin/elasticsearch-certutil cert \
  --ca /certs/elastic-ca.p12 \
  --ca-pass "" \
  --out /certs/elastic-certificates.p12 \
  --pass "" \
  --name elk-single-node \
  --dns elasticsearch,logstash,kibana,filebeat \
  --ip 127.0.0.1
这样得到一个 elastic-certificates.p12，里面包含私钥+证书。

3️⃣ 将 .p12 转换为 .crt 和 .key
导出 CA 证书 (elastic-ca.crt)
openssl pkcs12 -in elastic-ca.p12 -clcerts -nokeys -out elastic-ca.crt -passin pass:

导出节点证书 (elastic-cert.crt)
openssl pkcs12 -in elastic-certificates.p12 -clcerts -nokeys -out elastic-certificates.crt -passin pass:

导出节点私钥 (elastic-cert.key)
openssl pkcs12 -in elastic-certificates.p12 -nocerts -nodes -out elastic-certificates.key -passin pass:
（因为 --pass ""，所以 -passin pass: 后面是空的）

4️⃣ 生成结果
你最终会有：
	• elastic-ca.p12 → CA（二进制格式）
	• elastic-ca.crt → CA 公钥（PEM 格式）
	• elastic-certificates.p12 → 节点证书（二进制格式）
	• elastic-cert.crt → 节点证书（PEM 格式）
	• elastic-cert.key → 节点私钥（PEM 格式）

5️⃣ 使用建议
	• Elasticsearch 可以直接用 .p12（官方推荐）
	• Logstash / Filebeat / Kibana 通常用 .crt + .key + ca.crt

logstash 需要自定义权限写入elasticsearch,此处用了elastic用户；
