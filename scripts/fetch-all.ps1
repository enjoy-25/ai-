# 一键克隆本库收录的全部开源项目（只读用途，不修改上游）
# 用法： pwsh ./scripts/fetch-all.ps1 -Dest D:\src\ai-refs [-Shallow]
param(
    [string]$Dest = "$PWD/vendor",
    [switch]$Shallow
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "未找到 git。请先安装 Git for Windows，或用 scripts/fetch-all.sh 在 WSL/macOS 下执行。"
}
New-Item -ItemType Directory -Force -Path $Dest | Out-Null

# 格式： 分类 | owner/repo | 说明
$repos = @(
    'A|applekourfeat/CameraCompositor|离线自动选景 + 水平仪 + APK（无许可，只读）',
    'A|gleikeen/Shotune|MIT，自拍引导闭环设计文档',
    'A|sourishnandy4-cell/PosePilot|MIT，MediaPipe 实时体态引导，可直接跑',
    'A|Yansyah0209/PHIRA|黄金比例构图引导（无许可）',
    'A|clifftseng/AI-Camera|全端侧姿态+构图+调色（无许可）',
    'A|Ccchen1234/ai-composition-assistant|Android 构图助手（无许可）',
    'A|ksesidhar/AstraX|初学者 AI 相机（无许可）',
    'A|LiveCompose/LiveCompose|RL 主动引导移动手机（Python，算法参考）',
    'A|LiveCompose/LiveCapture|LiveCompose 的 iOS 端（Swift）',
    'B|android/camera-samples|CameraX/Camera2 官方示例',
    'B|google-ai-edge/mediapipe|姿态/分割 Tasks，Android GPU delegate',
    'B|google-ai-edge/LiteRT|TFLite 后继运行时',
    'B|shubham0204/Depth-Anything-Android|单目深度 Android 推理 demo',
    'B|john-rocky/litert-models|NIMA 端侧美学评估（nima/ 子目录）',
    'B|androidx/media|Media3 Transformer 端侧剪辑',
    'B|alibaba/MNN|移动端推理引擎',
    'B|Tencent/ncnn|轻量推理引擎',
    'B|pytorch/executorch|PyTorch 端侧部署',
    'B|opencv/opencv|CV 基础库（Android SDK）',
    'B|pqpo/SmartCropper|边缘检测自动裁剪',
    'B|onuralpszr/CvCamera-Mobile|OpenCV + Camera2 骨架（MIT）',
    'C|BWGZK-keke/ProCrop|ProCrop 训练代码（AAAI 2025）',
    'C|zzqingz/CPIC|CPIC 训练代码（MIT）',
    'C|AIVRC/GAFIC|GAFIC 训练代码'
)

foreach ($line in $repos) {
    $cat, $name, $desc = $line -split '\|', 3
    $target = Join-Path $Dest ($name -replace '/', '__')
    if (Test-Path (Join-Path $target '.git')) {
        Write-Host "[skip] $name 已存在" -ForegroundColor DarkGray
        continue
    }
    Write-Host "[$cat] $name  — $desc" -ForegroundColor Cyan
    try {
        if ($Shallow) { git clone --depth 1 "https://github.com/$name.git" $target }
        else { git clone "https://github.com/$name.git" $target }
    } catch {
        Write-Warning "克隆失败：$name（$($_.Exception.Message)）"
    }
}

Write-Host "`n完成。目标目录：$Dest" -ForegroundColor Green
Write-Host "提醒：A 类多数仓库无 LICENSE，仅可阅读参考，禁止复制到自己的代码库。" -ForegroundColor Yellow
