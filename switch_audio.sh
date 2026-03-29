#!/bin/bash
CONF="/etc/modprobe.d/alsa-macbook.conf"

# 1. PipeWire関連を完全に封印（再起動なしでドライバを抜くための必須工程）
echo "オーディオのリソースを強制解放中..."
systemctl --user mask --now pipewire.socket pipewire-pulse.socket wireplumber.service pipewire.service 2>/dev/null
killall -9 qjackctl jackdbus jackd 2>/dev/null
# /dev/snd を掴んでいるプロセスを根こそぎ殺す（これが無いと rmmod できない）
sudo fuser -k /dev/snd/* 2>/dev/null
sleep 2

# 2. ドライバを「完全に」引き抜く
# 依存関係（intel -> hda_codec -> cs420x）の順で確実に消す
echo "既存ドライバをアンロード中..."
sudo modprobe -rv snd_hda_intel 2>/dev/null
sudo modprobe -rv snd_hda_codec_cs420x 2>/dev/null
sudo modprobe -rv snd_hda_codec_generic 2>/dev/null
sudo modprobe -rv snd_hda_core 2>/dev/null

# 3. モード判定と設定ファイルの操作
if [ -f "$CONF" ]; then
    echo ">>> 現在: スピーカー → 【イヤホン】へ切り替え"
    sudo rm "$CONF"
    # 設定反映のために再ロード
    sudo modprobe -v snd_hda_intel model=auto
else
    echo ">>> 現在: イヤホン → 【スピーカー】へ切り替え"
    echo "options snd-hda-intel model=macbook-retina" | sudo tee "$CONF"
    # パッチ版を先に、次にIntelをロード（順番が命）
    sudo modprobe -v snd_hda_codec_cs420x 2>/dev/null
    sudo modprobe -v snd_hda_intel index=0
    sleep 3
    # アンプを叩き起こす
    amixer -c 0 sset 'Master' 80% unmute 2>/dev/null
    amixer -c 0 sset 'Speaker' 100% unmute 2>/dev/null
fi

# 4. 封印解除と復旧
echo "オーディオサービスを復旧中..."
systemctl --user unmask pipewire.socket pipewire-pulse.socket wireplumber.service pipewire.service 2>/dev/null
systemctl --user start pipewire pipewire-pulse wireplumber 2>/dev/null
sleep 2

# 5. qJackCtl を再起動
nohup qjackctl --start > /dev/null 2>&1 &

echo "作業完了。alsamixer で [Speaker] が出ているか確認してください。"
