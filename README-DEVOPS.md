# Nexvion – CI/CD (GitHub → Jenkins → Docker → AWS EC2)

```
git push → GitHub Webhook → Jenkins → docker build
        → push Docker Hub → SSH EC2 → docker compose pull/up → LIVE (port 80)
```

## 1. AWS setup (2 EC2 instances, Ubuntu 22.04)
| Server | Type | Security Group inbound |
|---|---|---|
| Jenkins | t2.medium | 22 (your IP), 8080 (anywhere) |
| App | t2.micro | 22 (Jenkins IP), 80 (anywhere) |

- App EC2: `sudo bash deploy/setup-ec2.sh`
- Jenkins EC2: `sudo bash deploy/setup-jenkins.sh`
- (Chhota setup: dono kaam ek hi EC2 pe bhi ho sakte hain.)

## 2. Jenkins config
Open `http://<JENKINS_IP>:8080` → plugins: **Git, GitHub, Pipeline, SSH Agent, Credentials Binding**.

Manage Jenkins → Credentials → add:
| ID | Type | Value |
|---|---|---|
| `dockerhub-creds` | Username+Password | Docker Hub user + access token |
| `nexvion-ec2-ssh` | SSH Username with private key | user `ubuntu`, App EC2 ka .pem key |
| `nexvion-ec2-host` | Secret text | App EC2 public IP/DNS |

New Item → **Pipeline** → "Pipeline script from SCM" → Git → repo URL → branch `main` → Script Path `Jenkinsfile`.
Build Triggers → tick **GitHub hook trigger for GITScm polling**.

## 3. GitHub webhook
Repo → Settings → Webhooks → Add: `http://<JENKINS_IP>:8080/github-webhook/` , type `application/json`, event: *push*.

## 4. Jenkinsfile edit
`IMAGE_NAME` me `YOUR_DOCKERHUB_USERNAME` apna username daalo (aur EC2 user Amazon Linux ho to `ec2-user`, `APP_DIR` bhi badlo).

## 5. Local test
```
docker compose up -d --build     # http://localhost
docker volume ls | grep nexvion  # nexvion_logs
docker compose down              # volume bacha rahega (-v se delete)
```
