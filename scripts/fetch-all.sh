#!/usr/bin/env bash
# 一键克隆本库收录的全部开源项目（只读用途，不修改上游）
# 用法： bash ./scripts/fetch-all.sh [目标目录] [--shallow]
set -uo pipefail

DEST="${1:-./vendor}"
SHALLOW="${2:-}"
command -v git >/dev/null 2>&1 || { echo "未找到 git，请先安装。"; exit 1; }
mkdir -p "$DEST"

REPOS=$(cat <<'EOF'
A applekourfeat/CameraCompositor   离线自动选景 + 水平仪 + APK（无许可，只读）
A gleikeen/Shotune                 MIT，自拍引导闭环设计文档
A sourishnandy4-cell/PosePilot     MIT，MediaPipe 实时体态引导，可直接跑
A Yansyah0209/PHIRA                黄金比例构图引导（无许可）
A clifftseng/AI-Camera             全端侧姿态+构图+调色（无许可）
A Ccchen1234/ai-composition-assistant  Android 构图助手（无许可）
A ksesidhar/AstraX                 初学者 AI 相机（无许可）
A LiveCompose/LiveCompose          RL 主动引导移动手机（Python，算法参考）
A LiveCompose/LiveCapture          LiveCompose 的 iOS 端（Swift）
B android/camera-samples           CameraX/Camera2 官方示例
B google-ai-edge/mediapipe         姿态/分割 Tasks，Android GPU delegate
B google-ai-edge/LiteRT            TFLite 后继运行时
B shubham0204/Depth-Anything-Android  单目深度 Android 推理 demo
B john-rocky/litert-models         NIMA 端侧美学评估（nima/ 子目录）
B androidx/media                   Media3 Transformer 端侧剪辑
B alibaba/MNN                      移动端推理引擎
B Tencent/ncnn                     轻量推理引擎
B pytorch/executorch               PyTorch 端侧部署
B opencv/opencv                    CV 基础库（Android SDK）
B pqpo/SmartCropper                边缘检测自动裁剪
B onuralpszr/CvCamera-Mobile       OpenCV + Camera2 骨架（MIT）
C BWGZK-keke/ProCrop               ProCrop 训练代码（AAAI 2025）
C zzqingz/CPIC                     CPIC 训练代码（MIT）
C AIVRC/GAFIC                      GAFIC 训练代码
EOF
)

echo "$REPOS" | while read -r cat name desc; do
    [ -z "${name:-}" ] && continue
    target="$DEST/${name//\//__}"
    if [ -d "$target/.git" ]; then
        echo "[skip] $name 已存在"
        continue
    fi
    echo "[$cat] $name — $desc"
    if [ "$SHALLOW" = "--shallow" ]; then
        git clone --depth 1 "https://github.com/$name.git" "$target" || echo "  克隆失败：$name"
    else
        git clone "https://github.com/$name.git" "$target" || echo "  克隆失败：$name"
    fi
done

echo
echo "完成。目标目录：$DEST"
echo "提醒：A 类多数仓库无 LICENSE，仅可阅读参考，禁止复制到自己的代码库。"
