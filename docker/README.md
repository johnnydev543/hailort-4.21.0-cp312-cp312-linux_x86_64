# Docker 環境 — HailoRT 測試容器

本目錄包含建構 HailoRT 測試環境的 Docker 設定檔。

## 目錄結構

```
docker/
├── README.md
├── Dockerfile           # 主要映像檔建構定義
├── docker-compose.yml   # Docker Compose 編排設定
├── requirements.txt     # Python 依賴套件清單
└── start-service.sh     # 容器啟動入口腳本
```

## 功能特色

- **HailoRT 4.21.0** — 預裝 HailoRT runtime library（deb 套件）
- **Python 3 + venv** — 自動建立 `/root/venv` 虛擬環境
- **Hailo PCIe 自動偵測** — 啟動時自動掃描 Hailo PCIe 裝置
- **SSH 選擇性啟用** — 透過 `ENABLE_SSH` build arg 控制

## 建構映像檔

### 啟用 SSH（預設）

```bash
cd docker
docker compose build
```

或直接使用 `docker build`：

```bash
docker build -t hailo-env:local .
```

### 停用 SSH

```bash
docker build --build-arg ENABLE_SSH=false -t hailo-env:nossh .
```

> 當 `ENABLE_SSH=false` 時，映像檔不會安裝 `openssh-server`，也不會設定 SSH 相關配置，容器會以 `sleep infinity` 保持運行。

## 啟動容器

```bash
cd docker
docker compose up -d
```

### 透過 SSH 連線（僅限啟用 SSH 時）

```bash
ssh root@localhost -p 8222
# 密碼：root
```

### 進入容器 Shell

```bash
docker exec -it hailo_env bash
```

進入後啟用 Python venv：

```bash
source /root/venv/bin/activate
```

## 安裝 Python 依賴

`requirements.txt` 列出了可選的 Python 套件（FastAPI、PyTorch 等），可在容器內手動安裝：

```bash
source /root/venv/bin/activate
pip install -r /path/to/docker/requirements.txt
```

## 環境變數與 Build Arguments

| 參數 | 預設值 | 說明 |
|------|--------|------|
| `ENABLE_SSH` | `true` | 是否安裝並啟用 SSH server |

## 磁碟區掛載

| 主機路徑 | 容器路徑 | 說明 |
|----------|----------|------|
| `./volumes/root` | `/root` | 持久化 home 目錄（含 venv） |
| `/var/run/hailo` | `/var/run/hailo` | Hailo daemon socket |
| `/etc/localtime` | `/etc/localtime` | 同步主機時區 |

## 硬體需求

- Hailo PCIe 裝置（如 Hailo-8 / Hailo-8L）
- 主機需載入 `hailo` 核心模組
- Docker 需以 `--privileged` 或 `--device /dev/hailo0` 啟動