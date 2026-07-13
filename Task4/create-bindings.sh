#!/usr/bin/env bash
# Привязка групп пользователей к ролям (RBAC bindings).
set -euo pipefail

# 1) Привилегированные: DevOps платформы -> cluster-admin (весь кластер)
kubectl create clusterrolebinding platform-admins-binding \
  --clusterrole=cluster-admin --group=platform-admins

# 2) Привилегированные: ИБ -> security-auditor (просмотр + секреты, весь кластер)
kubectl create clusterrolebinding security-binding \
  --clusterrole=security-auditor --group=security

# 3) Настройка кластера: разработчики домена -> domain-editor в своём namespace
#    (пример для домена sales; для других доменов — аналогично со своей группой)
kubectl create rolebinding sales-developers-edit \
  --clusterrole=domain-editor --group=sales-developers -n sales

# 4) Только просмотр: viewers -> view во всех доменных namespace
for ns in sales gku finance data; do
  kubectl create rolebinding viewers-view \
    --clusterrole=view --group=viewers -n "${ns}"
done

echo "Готово. Проверка: kubectl get clusterrolebindings,rolebindings -A | grep -E 'platform-admins|security|developers|viewers'"
