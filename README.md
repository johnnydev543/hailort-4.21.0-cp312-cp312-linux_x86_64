# HailoRT 4.21.0 Python 3.12 (Linux x86_64) 手動編譯與部署指南

本說明文件記錄了在較新版本的 Linux 系統（如 Ubuntu 24.04，配備較新版 CMake 3.30+ 與 Python 3.12）環境下，如何從原始碼手動編譯並安裝 **HailoRT 4.21.0** 驅動與 Python 3.12 虛擬環境（venv）專用 Wheel 檔的完整流程。

此方法解決了官方 Developer Zone 移除舊版下載點、新版 CMake 與舊版第三方套件相容性衝突（`Compatibility with CMake < 3.5 has been removed`），以及 PCIe 驅動與韌體版本不匹配的問題。

---

## 📌 環境準備

在開始編譯前，請先確保系統已安裝基礎編譯工具、Linux 核心標頭檔以及 Python 打包相關套件。


```bash
# 更新系統軟體包
sudo apt update
sudo apt install -y build-essential cmake git wget dkms linux-headers-$(uname -r)

# 建立並啟用 Python 3.12 虛擬環境 (venv)
python3 -m venv venv
source venv/bin/activate

# 在 venv 內安裝 Python 編譯工具
pip install --upgrade pip
pip install pybind11 mako wheel setuptools

```

---

## 🛠️ 步驟一：編譯與安裝 PCIe 核心驅動 (Driver)

為了讓作業系統能夠正常識別 Hailo-8 硬體，必須先下載並編譯驅動程式。

```bash
# 1. 複製驅動專案並切換至 v4.21.0 標籤
git clone --depth 1 --branch v4.21.0 https://github.com/hailo-ai/hailort-drivers.git
cd hailort-drivers/linux/pcie

# 2. 編譯並安裝驅動核心模組
sudo make all
sudo make install

# 3. 載入 PCIe 驅動
sudo modprobe hailo_pci

# 4. 驗證驅動是否成功掛載
lsmod | grep hailo_pci

```

---

## 🛠️ 步驟二：解決 CMake 相容性衝突並編編 C++ 核心庫

由於新版 CMake 嚴格限制最低版本必須 $\ge 3.5$，而 Hailo 舊版引入的第三方套件宣告過舊，因此需要地毯式修正其 `CMakeLists.txt`。

```bash
# 1. 回到家目錄並複製主專案原始碼 (v4.21.0 標籤)
cd ~
git clone --depth 1 --branch v4.21.0 https://github.com/hailo-ai/hailort.git
cd hailort

# 2. 一鍵修正 external/ 目錄下所有外部套件的 CMake 最低版本要求為 3.5
find hailort/external/ -name "CMakeLists.txt" -exec sed -i 's/cmake_minimum_required(VERSION [0-9.]*)/cmake_minimum_required(VERSION 3.5)/g' {} +

# 3. 清除舊快取並進行 CMake 核心組態設定
rm -rf build
cmake -Bbuild -H. -DCMAKE_BUILD_TYPE=Release

# 4. 開始編譯核心庫 (libhailort 與 hailortcli)
cmake --build build --config Release

```

---

## 🛠️ 步驟三：打包與安裝 Python 3.12 Wheel 檔案

C++ 核心庫編譯完成後，即可利用兩段式編譯法，切換到 Python Binding 目錄，並指定編譯輸出的路徑進行打包。

```bash
# 1. 切換至 Python 綁定平台的封裝目錄
cd ~/hailort/hailort/libhailort/bindings/python/platform

# 2. 設定環境變數，將其導向剛才編譯好的 C++ build 目錄
export HAILO_BUILD_DIR=~/hailort/build

# 3. 打包產生適用於 Python 3.12 的 .whl 檔案
python3 setup.py bdist_wheel

# 4. 在 venv 啟用狀態下安裝產出的 Wheel 檔
pip install dist/hailort-4.21.0-cp312-cp312-linux_x86_64.whl

```

---

## 🛠️ 步驟四：恢復正確的韌體 (Firmware 4.21.0)

若先前晶片曾誤刷寫過非對應硬體介面的韌體（例如 `extended context switch buffer` 乙太網版本），請將其刷回標準 PCIe 版本的韌體。

```bash
# 1. 回到家目錄，從官方開源發行管道下載 4.21.0 正確版韌體
cd ~
wget https://github.com/hailo-ai/hailort/raw/v4.21.0/hailort/hailortcli/firmware/hailo8_fw.bin

# 2. 使用新編譯好的工具更新韌體 (路徑通常在 build/hailort/hailortcli/ 下，或直接使用系統工具)
~/hailort/build/hailort/hailortcli/hailortcli fw-update hailo8_fw.bin

# 3. 更新完成後，請將主機「完全關機後斷電，再重新冷開機」使硬體韌體生效。

```

---

## ✅ 最終驗證

完成上述所有步驟並重新開機後，啟用您的 `venv` 虛擬環境並執行以下指令進行測試：

### 1. 檢查硬體與韌體版本

```bash
~/hailort/build/hailort/hailortcli/hailortcli fw-control identify

```

*預期輸出：Firmware Version 應顯示 `4.21.0 (release, app)`，且無 extended 字樣。*

### 2. 檢查 Python 驅動套件

```bash
python3 -c "import hailo_platform; print('成功！HailoRT 版本為：', hailo_platform.__version__)"

```

*預期輸出：`成功！HailoRT 版本為： 4.21.0*`

---

## 💡 常見問題與排查 (Troubleshooting)

1. **Q: 執行 `setup.py` 時抱怨找不到某個 `.so` 檔案？**
* **A:** 請確保您有確實執行步驟二的 `cmake --build build`，且 `export HAILO_BUILD_DIR` 指向的路徑完全正確。


2. **Q: 出現 `Module hailo_pcie not found`？**
* **A:** 代表核心驅動未正確掛載，請回到步驟一重新執行 `sudo make install` 與 `sudo modprobe hailo_pci`，並確認 `lsmod` 能看到模組。
"""
