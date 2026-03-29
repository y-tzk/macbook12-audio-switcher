#!/bin/bash
CONF="/etc/modprobe.d/alsa-macbook.conf"

if [ -f "$CONF" ]; then
    # --- 【イヤホンモード】（提示された成功手順をそのまま実行） ---
    echo "イヤホンモード（標準ドライバ）へ強制切替中..."

    # 1. 成功時の封印手順
    systemctl --user mask --now pipewire.socket pipewire-pulse.socket wireplumber.service pipewire.service 2>/dev/null
    killall -9 qjackctl jackdbus jackd 2>/dev/null
    sudo fuser -k /dev/snd/* 2>/dev/null

    # 2. ドライバを完全に引き抜く
    sudo modprobe -rv snd_hda_intel

    # 3. パッチ設定ファイルを退避
    sudo mv "$CONF" "${CONF}.bak"

    # 4. 標準状態でロード（model=auto）
    sudo modprobe -v snd_hda_intel model=auto

    # 5. 封印解除と復旧
    systemctl --user unmask pipewire.socket pipewire-pulse.socket wireplumber.service pipewire.service 2>/dev/null
    systemctl --user start pipewire pipewire-pulse wireplumber 2>/dev/null
    sleep 2
    qjackctl --start &
    echo "切替完了！イヤホンから音が出るか確認してください。"

else
    # --- 【スピーカーモード】（提示された成功手順をそのまま実行） ---
    echo "スピーカーモードへ強制切替中..."

    # 1. 完全に黙らせる
    systemctl --user stop wireplumber.service pipewire-pulse.socket pipewire.socket pipewire.service 2>/dev/null
    killall -9 qjackctl jackdbus jackd 2>/dev/null
    sudo fuser -k /dev/snd/* 2>/dev/null

    # 2. 依存関係を含め、全てのモジュールを根こそぎ抜く
    sudo modprobe -rv snd_hda_intel snd_hda_codec_cs420x snd_hda_codec_generic snd_hda_core 2>/dev/null
    sleep 2

    # 3. パッチ設定を配置
    if [ -f "${CONF}.bak" ]; then
        sudo mv "${CONF}.bak" "$CONF"
    else
        echo "options snd-hda-intel model=macbook-retina" | sudo tee "$CONF"
    fi

    # 4. パッチ版ドライバを先にロードしてから intel を入れる
    sudo modprobe -v snd_hda_codec_cs420x 2>/dev/null
    sudo modprobe -v snd_hda_intel index=0

    # 5. デバイス認識待ち
    echo "デバイス認識待ち..."
    sleep 5

    # 6. アンプを叩き起こす
    amixer -c 0 sset 'Master' 80% unmute 2>/dev/null
    amixer -c 0 sset 'Speaker' 100% unmute 2>/dev/null

    # 7. 復旧
    systemctl --user start pipewire.socket pipewire.service wireplumber.service 2>/dev/null
    qjackctl --start &
    echo "完了！ alsamixer で [Master] が出ているか確認してください。"
fi
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
