# B 类 · Android 端侧积木（能直接上生产的依赖）

> 这一层不是「同类产品」，是你做产品的弹药库。按数据流排：**取景 → 感知 → 推理 → 决策 → 剪辑**。
> 星数/许可快照：2026-11-23。

---

## B1. 取景与相机管线

| 项目 | 星 | 许可 | 说明 |
| --- | --- | --- | --- |
| [`android/camera-samples`](https://github.com/android/camera-samples) | 5470 | 见仓库 LICENSE | CameraX / Camera2 官方最佳实践示例，**先跑通 CameraX 的 ImageAnalysis 背压处理** |
| [`onuralpszr/CvCamera-Mobile`](https://github.com/onuralpszr/CvCamera-Mobile) | 52 | MIT | OpenCV `JavaCamera2View` + Camera2，OpenCV 4.10–4.14 的现成骨架 |
| [`J0Nreynolds/AndroidOpenCVCamera`](https://github.com/J0Nreynolds/AndroidOpenCVCamera) | 33 | **GPL-3.0** | 实时预览帧处理的经典样板，但 GPL 会传染，**只读不链** |

**工程要点**：CameraX 的 `ImageAnalysis` 默认会丢帧；做 10–20Hz 感知必须用 `STRATEGY_KEEP_ONLY_LATEST` + 单独的推理线程 + 线程池限流，否则主线程一卡，引导框就抖。

---

## B2. 感知（谁在画面里、在哪、多大、离多远）

| 能力 | 推荐 | 星 | 许可 | 备注 |
| --- | --- | --- | --- | --- |
| 人体姿态 | [`google-ai-edge/mediapipe`](https://github.com/google-ai-edge/mediapipe) · Pose Landmarker | 37794 | Apache-2.0 | 33 关键点，Android GPU delegate 可跑 30fps；PosePilot 已验证 0.10.14 可用 |
| 主体分割 | MediaPipe Image Segmenter / **ML Kit Subject Segmentation** | — | Google SDK | ML Kit 是官方 on-device API，比自训模型省事；[文档](https://developers.google.com/ml-kit/vision/subject-segmentation) |
| 单目深度 | [`shubham0204/Depth-Anything-Android`](https://github.com/shubham0204/Depth-Anything-Android) | 91 | Apache-2.0 | Depth-Anything / V2 的 Android 推理 demo，**判断「前景/中景/背景」层次的关键** |
| 深度（硬件） | ARCore Depth API | — | Google SDK | 有 ToF/双摄的机型直接拿米级深度，比单目估得准；CameraCompositor 已在用 |

> **「切换景物呈现层次」怎么落地**：深度图 → 按深度直方图切 2–3 层 → 检查层间是否有足够分离度 → 没有就让用户「往左半步让树和山分开」。这是规则，不是模型。

---

## B3. 推理运行时（决定你能不能塞进 200MB 的 App）

| 运行时 | 星 | 许可 | 适用 |
| --- | --- | --- | --- |
| [`google-ai-edge/LiteRT`](https://github.com/google-ai-edge/LiteRT) | 3615 | Apache-2.0 | TFLite 的后继，Android 一等公民，GPU/NPU delegate 最顺 |
| [`alibaba/MNN`](https://github.com/alibaba/MNN) | 16604 | Apache-2.0 | 国产机型适配好，支持 LLM + 视觉，转换工具成熟 |
| [`Tencent/ncnn`](https://github.com/Tencent/ncnn) | 24093 | BSD-3（含第三方） | 体积最小，移动端推理老牌 |
| [`pytorch/executorch`](https://github.com/pytorch/executorch) | 5191 | BSD | 想把 PyTorch 训练管线直接搬到端上时用（含 Android Llama demo） |

**选型建议**：模型来自 TFLite 生态 → LiteRT；要跑自己训的 PyTorch 构图模型 → 先导出 ONNX 再转 MNN/ncnn；别同时上三套。

---

## B4. 美学 / 构图打分（「推荐哪个框」的裁判）

| 项目 | 星 | 许可 | 说明 |
| --- | --- | --- | --- |
| [`john-rocky/litert-models`](https://github.com/john-rocky/litert-models) 的 `nima/` | — | 见仓库 | NIMA 画质/美学评估的 LiteRT GPU 端侧实现，**现成的端侧美学分** |
| NIMA 原论文（Google, 2017） | — | — | 输出 1–10 分分布而非单点，比回归更稳 |
| 自训 | — | — | 用 AVA / 你的垂类数据微调；注意**风格偏见**：糖水片高分、纪实低分 |

**关键判断**：端侧别用大模型打分。用 NIMA 这种小网 + 规则（三分线偏差、主体占比、地平线倾斜、留白比）混合，1–5ms 出结果，可解释、可调参。

---

## B5. 视频 / Vlog 端侧剪辑

| 项目 | 星 | 许可 | 说明 |
| --- | --- | --- | --- |
| [`androidx/media`](https://github.com/androidx/media)（Media3） | 3091 | Apache-2.0 | **Transformer** 做端侧裁剪/拼接/转码，取代已归档的 ffmpeg-kit |
| [`arthenica/ffmpeg-kit`](https://github.com/arthenica/ffmpeg-kit) | 5857 | LGPL-3.0 | ⚠️ **2026-07 已 ARCHIVED**，新项目别再用；已有项目尽快迁 Media3 |

**Vlog 侧的现实**：手机上做「按分镜自动粗剪」的算力瓶颈不在剪辑而在**选段**——哪 3 秒值得留。这块开源没有现成方案，`BeenLi/jianying-autocut`、`fanghengxuan/vlog-shot-breakdown` 都是离线/桌面思路，可借逻辑不可直接跑。

---

## B6. 其他可复用件

| 项目 | 星 | 许可 | 用途 |
| --- | --- | --- | --- |
| [`pqpo/SmartCropper`](https://github.com/pqpo/SmartCropper) | 4138 | 见仓库 LICENSE | 边缘检测自动裁剪 + 透视校正，**拍后裁切**环节可省很多事 |
| [`opencv/opencv`](https://github.com/opencv/opencv) | 91689 | Apache-2.0 | Android SDK 可用；直线检测（地平线）、显著性、光流都要它 |

---

## B7. 端侧能不能跑：一张现实检查表

| 需求 | 端侧可行 | 代价 |
| --- | --- | --- |
| 人体关键点 30fps | ✅ | 中端机 GPU delegate 稳定 |
| 主体分割 15fps | ✅ | ML Kit 或小分割网，~20MB |
| 单目深度 5–10fps | ✅ | Depth-Anything-V2-Small 量化后 ~30MB，中端机 8–15fps |
| 构图打分 | ✅ | NIMA-small，<5ms |
| 7B 级 VLM 实时对话 | ❌ | 端侧跑不动，只能云端；要 <300ms 首字基本不可能 |
| 「后退 0.8 米」 | ⚠️ | 需深度 + 地面平面，误差 20–30%，提示要用「退半步」这类模糊量词 |

> 结论：**感知和打分全端侧可行，语言级建议走云端 + 端侧兜底**。这也是 Pixel Camera Coach 大概率的分工。
