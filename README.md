# hummingbot-deploy

Welcome to the Hummingbot Deploy project. This guide will walk you through the steps to deploy multiple trading bots using a centralized dashboard powered by the Hummingbot API and comprehensive backend services.

## Prerequisites

- Docker must be installed on your machine. If you do not have Docker installed, you can download and install it from [Docker's official site](https://www.docker.com/products/docker-desktop).
- If you are on Windows, you'll need to setup WSL2 and a Linux terminal like Ubuntu. Make sure to run the commands below in a Linux terminal and not in the Windows command prompt or Powershell.

## Architecture

This deployment includes:

- **Dashboard** (port 8501): Streamlit-based web UI for bot management and monitoring
- **Hummingbot API** (port 8000): FastAPI backend service for bot operations and data management
- **PostgreSQL Database** (port 5432): Persistent storage for bot configurations and performance data
- **EMQX Broker** (port 1883): MQTT broker for real-time bot communication and telemetry

All services are orchestrated using Docker Compose for seamless deployment and management.

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/hummingbot/deploy.git
   cd deploy
   ```

## Running the Application

1. **Start and configure the Application**
   - Run the following command to download and start the app.
   - ```bash
     bash setup.sh
     ```
2. **Access the services:**
   - **Dashboard**: Open your web browser and go to `localhost:8501`. Replace `localhost` with the IP of your server if using a cloud server.
   - **API Documentation**: Access the Hummingbot API docs at `localhost:8000/docs`
   - **EMQX Dashboard**: Monitor MQTT broker at `localhost:18083` (admin/public)

3. **API Keys and Credentials:**
   - Go to the credentials page
   - You add credentials to the master account by picking the exchange and adding the API key and secret. This will encrypt the keys and store them in the master account folder.
   - If you are managing multiple accounts you can create a new one and start adding new credentials there.

4. **Create a config for PMM Simple**
   - Go to the tab PMM Simple and create a new configuration. Soon will be released a video explaining how the strategy works.

5. **Deploy the configuration**
   - Go to the Deploy tab, select a name for your bot, the image hummingbot/hummingbot:latest and the configuration you just created.
   - Press the button to create a new instance.

6. **Check the status of the bot**
   - Go to the Instances tab and check the status of the bot.
     - If it's not available is because the bot is starting, wait a few seconds and refresh the page.
     - If it's running, you can check the performance of it in the graph, refresh to see the latest data.
     - If it's stopped, probably the bot had an error, you can check the logs in the container to understand what happened.

7. **[Optional] Monitor Services**
   - **Hummingbot API**: Access full API documentation at `localhost:8000/docs`
   - **Database**: PostgreSQL running on `localhost:5432` (hbot/hummingbot-api)
   - **MQTT Broker**: EMQX dashboard at `localhost:18083` for real-time bot communication monitoring

## 本地运行快速指引（中文）

### 一、准备工作
- 安装 Docker / Docker Desktop，并确保可以在终端执行 `docker` 和 `docker compose`。
- **Windows 用户**：
  - 推荐安装 WSL2 并在 Ubuntu 终端中操作。
  - 如果使用原生 PowerShell，**需要先绕过脚本执行策略**（见下方说明）。

### 二、首次运行（推荐使用一键安装脚本）

#### Linux / macOS / WSL
```bash
bash setup.sh
```

#### Windows (PowerShell)
如果直接运行 `.\setup.ps1` 报错“在此系统上禁止运行脚本”，请使用以下命令绕过策略执行：
```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```
脚本执行过程中会生成 `.env` 配置文件，并自动拉取镜像启动服务。

#### 访问服务
等脚本执行结束后，在浏览器访问：
- Dashboard：`http://localhost:8501`
- API Docs：`http://localhost:8000/docs`

> 提示：脚本过程中会让你输入 Dashboard 用户名 / 密码等信息，直接回车即可使用默认值 `admin`，也可以按需自定义。

### 三、后续每天使用（一键启动脚本）

#### Linux / macOS / WSL
```bash
bash start.sh
```

#### Windows (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -File .\start.ps1
```
或者如果你已经永久修改了执行策略，直接运行 `.\start.ps1`。

如需停止所有服务，可以执行：
```bash
docker compose down
```

### 四、完全手动运行方式（不用脚本也可以）
如果你更喜欢完全手动控制，也可以只使用 Docker Compose：

1. **首次运行：**
   - 确保已经有 `.env` 文件（可以先执行一次 `bash setup.sh` 生成；或者自己手工创建，参考 `setup.sh` 中写入 `.env` 的字段）。
   - 在项目根目录执行：
     ```bash
     docker compose pull
     docker pull hummingbot/hummingbot:latest
     docker compose up -d
     ```

2. **之后每天启动：**
   ```bash
   docker compose up -d
   ```

3. **查看日志：**
   ```bash
   docker compose logs -f
   ```

4. **停止并关闭：**
   ```bash
   docker compose down
   ```

### 五、可选配置：安全和云存储

- **Dashboard 登录账号**：可以通过修改项目根目录的 `credentials.yml` 来调整默认用户名 / 密码，然后在 `docker-compose.yml` 中将 `AUTH_SYSTEM_ENABLED` 设置为 `True`，再重新运行 `bash setup.sh` 或 `bash start.sh`。
- **AWS/S3 相关配置**：如果需要把数据备份到 S3，可以：
  - 直接编辑 `.env` 文件中的 `AWS_API_KEY`、`AWS_SECRET_KEY` 和 `AWS_S3_DEFAULT_BUCKET_NAME` 字段；
  - 或者修改 `setup.sh` 中对应的变量后重新执行一次。

以上就是本地运行和一键启动的简要中文说明，你可以直接记住两个常用命令：

- 首次安装和启动：`bash setup.sh`
- 之后每天启动：`bash start.sh`

## Authentication

Authentication is disabled by default. To enable Dashboard Authentication please follow the steps below: 

**Set Credentials (Optional):**

The dashboard uses `admin` and `abc` as the default username and password respectively. It's strongly recommended to change these credentials for enhanced security.:

- Navigate to the `deploy` folder and open the `credentials.yml` file.
- Add or modify the current username / password and save the changes afterward
  
  ```
  credentials:
    usernames:
      admin:
        email: admin@gmail.com
        name: John Doe
        logged_in: False
        password: abc
  cookie:
    expiry_days: 0
    key: some_signature_key # Must be string
    name: some_cookie_name
  pre-authorized:
    emails:
    - admin@admin.com
  ```  
### Enable Authentication

- Ensure the dashboard container is not running.
- Open the `docker-compose.yml` file within the `deploy` folder using a text editor.
- Locate the environment variable `AUTH_SYSTEM_ENABLED` under the dashboard service configuration.
  
  ```
  services:
  dashboard:
    container_name: dashboard
    image: hummingbot/dashboard:latest
    ports:
      - "8501:8501"
    environment:
        - AUTH_SYSTEM_ENABLED=True
        - BACKEND_API_HOST=hummingbot-api
        - BACKEND_API_PORT=8000
  ```
- Change the value of `AUTH_SYSTEM_ENABLED` from `False` to `True`.
- Save the changes to the `docker-compose.yml` file.
- Relaunch Dashboard by running `bash setup.sh`
  
### Known Issues
- Refreshing the browser window may log you out and display the login screen again. This is a known issue that might be addressed in future updates.


## Dashboard Functionalities

- **Config Generator:**
  - Create and select configurations for different v2 strategies.
  - Backtest and deploy the selected configurations.

- **Bot Management:**
  - Visualize bot performance in real-time.
  - Stop and archive running bots.

## Tutorial

To get started with deploying your first bot, follow these step-by-step instructions:

1. **Prepare your bot configurations:**
   - Select a controller and backtest your controller configs.

2. **Deploy a bot:**
   - Use the dashboard UI to select and deploy your configurations.

3. **Monitor and Manage:**
   - Track bot performance and make adjustments as needed through the dashboard.
