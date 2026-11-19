# Lab 7 - Jenkins, Maven, Nexus va SonarQube

Repository: https://github.com/BangViet0311/devops-lab7-ci-demo

## Ket qua da kiem tra

- Jenkins build **#2**: **SUCCESS**, 6/6 tests pass.
- URL: http://localhost:8080/job/DevOps-Lab7-CI-Pipeline/2/
- Revision source: `d607e657f864431666aa5cc83a5cf8bb4c095f7e`.
- Jenkins da archive `ci-demo-1.0.0-SNAPSHOT.jar`.
- Nexus da luu `ci-demo-1.0.0-20261119.024438-1.jar` trong `maven-snapshots`.
- SonarQube project `devops-lab7` da phan tich, dashboard hien Quality Gate Passed.
- Anh 01 den 08 co trong `screenshots/`. Anh Console Output la anh toan trang.
- Build #1 loi 401 vi credential Nexus; da cap nhat credential va chay lai
  thanh cong o build #2. Giu nguyen lich su build de doi chieu.

SonarQube 9.9.8 hien canh bao het ho tro va dung embedded database: chi dung
cho lab local. Khong dua stack nay ra Internet/production voi cau hinh hien tai.

## Cau truc

```text
configs/
  docker-compose.yml
  Jenkinsfile
  maven-settings-nexus.xml
  sample-java-app/
    pom.xml
    src/main/java/com/devops/Calculator.java
    src/test/java/com/devops/CalculatorTest.java
scripts/
  setup.ps1
  verify.ps1
  cleanup.ps1
screenshots/
```

## Chay tren Windows PowerShell

Tu thu muc goc repository:

```powershell
.\scripts\setup.ps1
.\scripts\verify.ps1
mvn -f .\configs\sample-java-app\pom.xml clean verify
```

Jenkins: http://localhost:8080 - Nexus: http://localhost:8081 - SonarQube: http://localhost:9000

Day la cau hinh lab local, khong dung truc tiep cho production.

## Cau hinh Jenkins

Plugins: Pipeline (gom Declarative), Git, JUnit, Credentials Binding,
Pipeline: Stage View, SonarQube Scanner, Config File Provider.

1. Manage Jenkins > Tools: Maven tu dong cai dat, ten **M3**, phien ban 3.9.x.
2. Credentials (Global):
   - **sonarqube-token**: Secret text, token phan tich project `devops-lab7`.
   - **nexus-credentials**: Username with password, tai khoan duoc phep deploy Nexus.
3. Manage Jenkins > System > SonarQube servers:
   - Name: **SonarQube**.
   - Server URL: **http://lab7-sonarqube:9000**.
   - Authentication token: **sonarqube-token**.
4. Managed files: Maven settings.xml, ID **maven-settings-nexus**.
   Copy noi dung `configs/maven-settings-nexus.xml`. Khong dien mat khau that;
   khong them Server Credentials mappings vi pipeline dung bien moi truong.
5. Nexus: repository **maven-snapshots**, format maven2 (hosted), policy Snapshot.
6. SonarQube: project key **devops-lab7**; token co quyen Execute Analysis.

### Pipeline job

- Name: **DevOps-Lab7-CI-Pipeline**; type: **Pipeline**.
- Definition: **Pipeline script from SCM**; SCM: **Git**.
- URL: **https://github.com/BangViet0311/devops-lab7-ci-demo.git**.
- Branch: ***/main**.
- Script Path: **configs/Jenkinsfile** (khong phai sample-java-app/Jenkinsfile).
- Repo private can them GitHub credential co quyen doc repository.
- Save > Build Now.

Pipeline: Checkout -> Build -> Test -> SonarQube Analysis -> Package and Archive -> Publish to Nexus.

Ket qua mong doi: 6 tests pass, Finished: SUCCESS, JAR duoc archive trong Jenkins
va publish vao `maven-snapshots/com/devops/lab7/ci-demo/1.0.0-SNAPSHOT/`.
Nexus doi ten file SNAPSHOT thanh ten co timestamp, day la hanh vi binh thuong.

SonarQube scan duoc gui len server; pipeline nay chua cho Quality Gate.
Khong co JaCoCo nen khong dung so tests pass de ket luan coverage.

### Tu dong build

Cach don gian cho Jenkins local: job > Configure > Triggers > Poll SCM,
schedule **H/5 * * * ***. Jenkins kiem tra moi khoang 5 phut va chi build
khi phat hien thay doi, khong phai luc nao cung build.

Neu can GitHub webhook: public Jenkins qua HTTPS tunnel, dat payload URL
`https://<tunnel>/github-webhook/` va bat GitHub hook trigger trong job.
GitHub khong truy cap duoc `http://localhost:8080` tren may cua ban.
Khong tat authentication cua Jenkins de lam webhook.

## Anh nop bai

Luu trong `screenshots/` (khong chup token hoac mat khau):

- 01-docker-ps.png: 3 containers Up.
- 02-jenkins-dashboard.png: Jenkins Dashboard.
- 03-pipeline-stage-view.png: tat ca stage xanh.
- 04-console-output.png: Finished: SUCCESS.
- 05-test-results.png: Jenkins Test Result, 6 tests pass.
- 06-artifacts.png: JAR trong build Jenkins.
- 07-nexus-artifact.png: JAR da publish trong Nexus Browse.
- 08-sonarqube-dashboard.png: project da phan tich (tuy chon theo rubric).

Bo sung ho_ten_mssv.txt voi thong tin that truoc khi dong goi nop bai.
Khong dong goi `.git`, `target`, mat khau hay token. Khong can tao file dap an
trong `solution/`; do la tai lieu cua giang vien.

## Don dep sau khi chup du anh

```powershell
.\scripts\cleanup.ps1
```

Script giu lai volumes. Khong dung `down -v` neu muon giu du lieu.
Chay lai `setup.ps1` de khoi dong lai.
