#!/usr/bin/env bash
set -euo pipefail

CERT_DIR="${CERT_DIR:-$(pwd)/certs}"
CA_CRT="${CA_CRT:-${HOME}/.minikube/ca.crt}"
CA_KEY="${CA_KEY:-${HOME}/.minikube/ca.key}"
CLUSTER="${CLUSTER:-minikube}"
DAYS="${DAYS:-365}"

mkdir -p "${CERT_DIR}"

create_user() {
  local user="$1" group="$2"
  echo ">> Пользователь ${user} (группа ${group})"
  openssl genrsa -out "${CERT_DIR}/${user}.key" 2048
  openssl req -new -key "${CERT_DIR}/${user}.key" \
    -out "${CERT_DIR}/${user}.csr" \
    -subj "/CN=${user}/O=${group}"
  openssl x509 -req -in "${CERT_DIR}/${user}.csr" \
    -CA "${CA_CRT}" -CAkey "${CA_KEY}" -CAcreateserial \
    -out "${CERT_DIR}/${user}.crt" -days "${DAYS}"
  kubectl config set-credentials "${user}" \
    --client-certificate="${CERT_DIR}/${user}.crt" \
    --client-key="${CERT_DIR}/${user}.key" \
    --embed-certs=true
  kubectl config set-context "${user}" \
    --cluster="${CLUSTER}" --user="${user}"
}


create_user "devops1"    "platform-admins"    # привилегированные: cluster-admin
create_user "secops1"    "security"           # привилегированные: просмотр секретов
create_user "sales-dev1" "sales-developers"   # настройка кластера в namespace sales
create_user "manager1"   "viewers"            # только просмотр

echo "Готово. Список контекстов: kubectl config get-contexts"
