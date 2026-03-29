#!/bin/bash
CONF="/etc/modprobe.d/alsa-macbook.conf"

echo "オーディオ設定をイヤホンモード（標準構成）へ切り替えています..."

# 1. オーディオサービスを一時停止（排他利用の解除）
# リソース競合を回避し、ドライバのアンロードを確実に行います
systemctl --user mask --now pipewire.socket pipewire-pulse.socket wireplumber.service pipewire.service 2>/dev/null
killall -9 qjackctl jackdbus jackd 2>/dev/null
sudo fuser -k /dev/snd/* 2>/dev/null

# 2. オーディオドライバのアンロード
# 現在のセッションで使用されているモジュールを一度完全に解除します
sudo modprobe -rv snd_hda_intel

# 3. カスタム構成プロファイルを退避
# パッチ設定を無効化し、標準の自動認識（model=auto）が機能するようにします
if [ -f "$CONF" ]; then
    sudo mv "$CONF" "${CONF}.bak"
fi

# 4. 標準構成でのドライバ再ロード
# model=auto を指定し、ハードウェアの標準機能を初期化します
sudo modprobe -v snd_hda_intel model=auto

# 5. サービスの復旧と設定の反映
systemctl --user unmask pipewire.socket pipewire-pulse.socket wireplumber.service pipewire.service 2>/dev/null
systemctl --user start pipewire pipewire-pulse wireplumber 2>/dev/null
sleep 2
qjackctl --start &

echo "切り替えが完了しました。イヤホンから正常に音声が出力されるか確認してください。"
