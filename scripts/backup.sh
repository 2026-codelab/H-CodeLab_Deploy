#!/usr/bin/env bash
# DB 2개(web-db, dom-db)를 덤프해서 /home/codelab/hcl-backup 에 저장하고, 7일 지난 백업은 지운다.
# Jenkins 'hcl-backup' 작업이 매일 새벽 4시쯤 실행한다. 직접 실행: bash /home/codelab/hcl/scripts/backup.sh
set -euo pipefail
cd /home/codelab/hcl

OUT=/home/codelab/hcl-backup
TS=$(date +%Y%m%d-%H%M)

# 비밀번호는 각 DB 컨테이너 안의 환경변수를 그대로 쓴다
docker compose exec -T web-db sh -c 'exec mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" --single-transaction --routines --triggers handongjudge' \
  | gzip > "$OUT/web-db-$TS.sql.gz"
docker compose exec -T dom-db sh -c 'exec mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" --single-transaction --routines --triggers domjudge' \
  | gzip > "$OUT/dom-db-$TS.sql.gz"

# 빈 파일이면 실패로 본다
for f in "$OUT/web-db-$TS.sql.gz" "$OUT/dom-db-$TS.sql.gz"; do
  if [ "$(gzip -dc "$f" | head -c 100 | wc -c)" -lt 100 ]; then
    echo "백업이 비어 있습니다: $f"
    exit 1
  fi
done

find "$OUT" -name '*.sql.gz' -mtime +7 -delete
echo "백업 완료:"
ls -lh "$OUT" | tail -n 4
