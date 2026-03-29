#!/bin/bash
# 接続先(system)と接続元(PulseAudio)の名前を確認
# 環境によって 'PulseAudio' が 'PulseAudio Jack Sink' などに変わる場合があります
SRC_L="PulseAudio:front-left"
SRC_R="PulseAudio:front-right"

echo "4スピーカー・フルサウンドを有効化中..."

# 既存の接続を維持しつつ、残りのツイーター(3,4)にも線を繋ぐ
jack_connect "$SRC_L" system:playback_1 2>/dev/null
jack_connect "$SRC_L" system:playback_3 2>/dev/null
jack_connect "$SRC_R" system:playback_2 2>/dev/null
jack_connect "$SRC_R" system:playback_4 2>/dev/null

echo "完了！ 全4基のスピーカーから音が出ているか確認してください。"
