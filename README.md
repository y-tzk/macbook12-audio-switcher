# macbook12-audio-switcher
Audio Switcher for MacBook 12 (A1534) on Linux. Toggle between Internal Speaker and Headphones without reboot. (Kernel 6.18+ support)

Based on the driver by [leifliddy/macbook12-audio-driver](https://github.com).

Linux カーネル 6.18 以降の MacBook 12 (A1534) で、再起動なしにスピーカーとイヤホンを切り替えるためのスクリプトです。
 leifliddy/macbook12-audio-driverの使用を前提としています。

## Features / 特徴
- **Toggle without Reboot**: Switch audio mode instantly by reloading drivers.
- **Kernel 6.18+ Support**: Tested on 6.18.20-1-lts (EndeavourOS).
- **Auto-Fix**: Automatically handles PipeWire/WirePlumber and Jack processes.

- **再起動不要**: ドライバを強制リロードして即座に切り替えます。
- **最新カーネル対応**: 6.18.20-1-lts (EndeavourOS) で動作確認済み。
- **自動復旧**: PipeWire や qJackCtl の停止・再起動も自動で行います。

## Requirements / 必要条件
- `leifliddy/macbook12-audio-driver` installed.
- `pipewire`, `wireplumber`, `alsa-utils`, `qjackctl`.

## Usage / 使い方
1. Download `switch_audio.sh`.
2. Give execution permission:
   ```bash
   chmod +x switch_audio.sh
   ```
3. Run with sudo
   ```bash
   sudo ./switch_audio.sh
   ```

### Individual Scripts / 個別スクリプト
If you want to set a specific mode directly:
特定のモードに直接固定したい場合：
- `set_speaker.sh`: Force to Speaker / スピーカーに固定
- `set_headphone.sh`: Force to Headphone / イヤホンに固定

### Tips: Full 4-Speaker Audio (JACK)
To enable all 4 speakers, connect your output to all 4 playback ports:
全4スピーカーを有効にするには、JACKで以下のように接続してください：
- **Left Source** -> `playback_1` & `playback_3`
- **Right Source** -> `playback_2` & `playback_4`
You can automate this using **QjackCtl Patchbay**.

MacBook 12-inch features a **4-speaker system**: two main speakers on the sides and two tweeters in the center. By default, only 2 ports may be connected. Connecting all 4 playback ports significantly improves sound richness and clarity.
macbook12は４スピーカー構成で、サイドに２つのメインスピーカーと中央に２つのツイーターがあります。４つに繋ぐと音が良くなった気がします。

 ## Tested Environment / 動作確認済み環境
 **Model**: MacBook 12-inch (A1534 / Early 2015, 2016, 2017)
 **OS**: EndeavourOS (Arch Linux based)
 **Kernel**: 6.18.20-1-lts
 **Desktop**: LXQt
 **Sound Server**: PipeWire / WirePlumber

If you have tested this script on other distros, please feel free to leave a comment in the **[Discussions](https://github.com/y-tzk/macbook12-audio-switcher/discussions/1)** section. 
(No direct support provided for other environments.)

 ---
## Disclaimer / 免責事項
- **Use at your own risk.** I am not responsible for any damage to your hardware or software.
- This script modifies system files (`/etc/modprobe.d/`) and reloads kernel modules.
- Ensure you have a backup of your data before running these scripts.

- **自己責任で使用してください。** このスクリプトの使用によって生じたハードウェアやソフトウェアの損害について、作者は一切の責任を負いません。
- このスクリプトはシステムファイル（`/etc/modprobe.d/`）を書き換え、カーネルモジュールをリロードします。
- 実行前に必ずデータのバックアップを取ってください。

