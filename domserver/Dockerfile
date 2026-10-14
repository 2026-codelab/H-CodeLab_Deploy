# 공식 DOMjudge 이미지 + H-CodeLab 전용 채점 결과 API (JudgementController.php)
# 컨트롤러 원본은 2026-codelab/Domjudge 레포 master 에 있고, 빌드할 때마다 최신 파일을 내려받는다.
# 버전을 올릴 때는 judgehost 이미지 버전도 같이 올리고, 컨트롤러가 새 버전과 맞는지 확인한다.
FROM domjudge/domserver:9.0.0

ADD --chmod=644 https://raw.githubusercontent.com/2026-codelab/Domjudge/master/webapp/src/Controller/API/JudgementController.php \
    /opt/domjudge/domserver/webapp/src/Controller/API/JudgementController.php
