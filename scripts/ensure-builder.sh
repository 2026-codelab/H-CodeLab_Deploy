#!/usr/bin/env bash
# 이미지 빌드가 judgehost 코어를 쓰지 않도록 SYSTEM_CPUS 코어만 쓰는 buildx 빌더를 만든다.
# 이미 있으면 그대로 둔다. Jenkins 파이프라인이 빌드 전에 호출한다.
set -euo pipefail
docker buildx inspect hcl-builder >/dev/null 2>&1 && exit 0
# 코어 목록에 쉼표가 있으면(예: 0-3,24-27) 따옴표로 감싸야 buildx 가 한 값으로 읽는다
# 다른 작업이 같은 순간에 먼저 만들었으면 create 가 실패하므로, 그때는 이미 있는 빌더를 그대로 쓴다
docker buildx create --name hcl-builder --driver docker-container --driver-opt "\"cpuset-cpus=${SYSTEM_CPUS}\""   || docker buildx inspect hcl-builder >/dev/null
docker buildx inspect --bootstrap hcl-builder
