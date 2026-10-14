#!/usr/bin/env bash
# /home/codelab/hcl/.env 를 처음 한 번 만든다. 비밀번호는 자동으로 무작위 생성한다.
# 사용법: bash scripts/gen-env.sh
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  echo ".env 가 이미 있습니다. 덮어쓰면 DB 비밀번호가 바뀌어 접속이 안 되므로 중단합니다."
  exit 1
fi

rand() { openssl rand -hex "$1"; }

read -rp "사이트 주소 (우리 서버: http://ai.walab.info): " SITE_URL
read -rp "judgehost 가 쓰지 않는 CPU 코어 (우리 서버: 0-3,24-27): " SYSTEM_CPUS
read -rsp "OpenAI API 키 (입력 내용은 화면에 안 보임): " LLM_API_KEY; echo
read -rp "메일 발송용 Gmail 주소 (없으면 Enter): " MAIL_USERNAME
MAIL_PASSWORD=""
if [ -n "$MAIL_USERNAME" ]; then
  read -rsp "Gmail 앱 비밀번호 (입력 내용은 화면에 안 보임): " MAIL_PASSWORD; echo
fi

case "$SITE_URL" in
  https://*) COOKIE_SECURE=true ;;
  *) COOKIE_SECURE=false ;;
esac

DOCKER_GID=$(getent group docker | cut -d: -f3)

umask 077
cat > .env <<EOF
# 생성: $(date '+%Y-%m-%d %H:%M')  /  형식 설명은 .env.example 참고

# ===== 서버 =====
SITE_URL=${SITE_URL}
COOKIE_SECURE=${COOKIE_SECURE}
SYSTEM_CPUS=${SYSTEM_CPUS}
DOCKER_GID=${DOCKER_GID}

# ===== DB / Redis =====
WEB_DB_ROOT_PASSWORD=$(rand 24)
WEB_DB_PASSWORD=$(rand 24)
DOM_DB_ROOT_PASSWORD=$(rand 24)
DOM_DB_PASSWORD=$(rand 24)
REDIS_PASSWORD=$(rand 24)

# ===== 백엔드 =====
JWT_SECRET_KEY=$(rand 64)
LLM_API_KEY=${LLM_API_KEY}
LLM_MODEL=gpt-4o-mini
MAIL_USERNAME=${MAIL_USERNAME}
MAIL_PASSWORD=${MAIL_PASSWORD}

# ===== DOMjudge (6단계에서 채운다) =====
JUDGEDAEMON_PASSWORD=
DOMJUDGE_API_USER=admin
DOMJUDGE_API_PASSWORD=
EOF

# Jenkins 컨테이너(docker 그룹)도 읽을 수 있게 한다
chgrp docker .env
chmod 640 .env

echo ".env 를 만들었습니다:"
grep -E '^(SITE_URL|COOKIE_SECURE|SYSTEM_CPUS|DOCKER_GID)=' .env
