#!/bin/bash
CONF="/etc/modprobe.d/alsa-macbook.conf"

echo "オーディオ設定をスピーカーモードへ切り替えています..."

# 1. オーディオサービスを一時停止（リソース競合の回避）
systemctl --user stop wireplumber.service pipewire-pulse.socket pipewire.socket pipewire.service 2>/dev/null
killall -9 qjackctl jackdbus jackd 2>/dev/null
sudo fuser -k /dev/snd/* 2>/dev/null

# 2. オーディオモジュールを完全にアンロード
# 依存関係を含め、メモリ上の既存設定をリセットします
sudo modprobe -rv snd_hda_intel snd_hda_codec_cs420x snd_hda_codec_generic snd_hda_core 2>/dev/null
sleep 2

# 3. パッチ適用済みの構成設定を配置
[ ! -f "$CONF" ] && echo "options snd-hda-intel model=macbook-retina" | sudo tee "$CONF"

# 4. パッチ適用済みドライバを優先的にロードし、ハードウェアを初期化
sudo modprobe -v snd_hda_codec_cs420x 2>/dev/null
sudo modprobe -v snd_hda_intel index=0

# 5. デバイスの安定待ち（ハードウェア認識に時間が必要です）
echo "ハードウェアを認識しています。少々お待ちください..."
sleep 5

# 6. ミキサー設定の最適化（ミュート解除と音量設定）
amixer -c 0 sset 'Master' 80% unmute 2>/dev/null
amixer -c 0 sset 'Speaker' 100% unmute 2>/dev/null

# 7. オーディオサービスの復旧
systemctl --user start pipewire.socket pipewire.service wireplumber.service 2>/dev/null
qjackctl --start &

echo "切り替えが完了しました。alsamixer 等で [Master] コントロールを確認してください。"
