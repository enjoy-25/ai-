# ai- · AI 摄影构图 / Vlog 辅助 App —— 开源项目选型库

> 目标产品：Android 相机界面，举起手机对准拍摄对象时——
> ① 框出推荐构图、给出裁切建议；② 引导你移动脚步 / 换机位、切换前后景层次、调整焦段；③ 视频侧按分镜给引导。
>
> 本仓库不存放第三方源码（许可原因，见文末），只做**筛选、评级、落地路径**，并附一键拉取脚本。

---

## 0. 结论先行（TL;DR）

| 判断 | 说明 |
| --- | --- |
| **没有「成品级」的 Android 开源对标** | 与你的设想重合度最高的 6 个 Android 仓库全是 0–4 星的个人原型/半成品，没有可直接商用的。LiveCompose 那套（RL 主动引导）只有 Python 训练代码 + iOS 客户端 |
| **最值得读的 3 份代码** | `applekourfeat/CameraCompositor`（唯一做到「离线自动选景 + 地标窗口 + 水平仪 + 可跑 APK」）> `gleikeen/Shotune`（MIT，闭环设计最完整）> `sourishnandy4-cell/PosePilot`（MIT，MediaPipe 姿态引导可直接跑） |
| **真正的护城河不在「打分」，在「引导」** | 学术侧 2025–2026 已经把「构图打分」卷完了（ProCrop/CropReward/CPIC），但**没有产品把「移动脚步/换焦段」变成实时闭环**。这是空档，也是难点（延迟 + 提示抖动 + 功耗） |
| **端侧积木已经齐全** | CameraX + MediaPipe(Pose/Segmenter) + Depth-Anything-Android + LiteRT/MNN + Media3 Transformer，整条链路在 2026 年都能在手机上跑通，缺的是把它们编排成 1–3Hz 的决策循环 |
| **Vlog 侧几乎无人做实时** | 开源侧只有「拉片/切片/生成脚本」的离线工具（vlog-shot-breakdown、jianying-autocut）。实时分镜引导是蓝海，参考 ACM TOMM 2023 的 AR 视频拍摄引导 |

---

## 1. 三类资产，别混着看

| 类别 | 定义 | 用法 | 目录 |
| --- | --- | --- | --- |
| **A. 直接同类** | Android 上真做了「构图引导/拍摄教练」的 App 原型 | 抄交互与工程结构，**不要抄代码**（多数无 license） | [`docs/01-direct-overlap.md`](docs/01-direct-overlap.md) |
| **B. 端侧积木** | 不解决你的产品问题，但提供能跑的能力（分割/深度/姿态/推理/剪辑） | 直接当依赖用，是量产路径 | [`docs/02-android-stack.md`](docs/02-android-stack.md) |
| **C. 算法与论文** | 构图/裁切/美学的最新方法 | 决定「推荐哪个框」的天花板 | [`docs/03-algorithms.md`](docs/03-algorithms.md) |

> 一句话选型：**A 决定你的产品形态，B 决定你能不能上架，C 决定你比别人准多少。**

---

## 2. 五个仓库，五种「重合度」

按「和你想做的东西有多像」排序，注意星数≠价值：

| 仓库 | 星 | 语言 | 许可 | Android 能跑 | 和你项目的重合点 | 你能拿走什么 |
| --- | --- | --- | --- | --- | --- | --- |
| [`applekourfeat/CameraCompositor`](https://github.com/applekourfeat/CameraCompositor) | 0 | Kotlin | ⚠️ 无 | ✅ 有 debug APK | **最高**：举起手机自动选景、主体被裁掉时提示换角度、水平仪引导、ARCore 可选 | 自动构图状态机、地标跟踪窗口容错、水平仪交互、APK 分发方式 |
| [`gleikeen/Shotune`](https://github.com/gleikeen/Shotune) | 4 | Kotlin | ✅ MIT | ⚠️ 仅文档 | 前摄自拍闭环：本地姿态 → 构图框 → 云端审美分 → 语音短句 → 达标提醒 | 产品设计文档（`shotune-camera-app-plan.md`）几乎就是一份 PRD |
| [`sourishnandy4-cell/PosePilot`](https://github.com/sourishnandy4-cell/PosePilot) | 1 | Kotlin | ✅ MIT | ✅ minSdk 24 | MediaPipe 0.10.14 实时体态 + 构图，Android/iOS 双端 | 姿态关键点 → 语言提示的最短实现路径 |
| [`Yansyah0209/PHIRA`](https://github.com/Yansyah0209/PHIRA) | 0 | Kotlin | ⚠️ 无 | ✅ Actions 出 APK | 黄金比例构图 + 相机引导，UI 克制 | 构图几何计算、Actions 打包流程 |
| [`clifftseng/AI-Camera`](https://github.com/clifftseng/AI-Camera) | 0 | Kotlin | ⚠️ 无 | ✅ | 姿态引导 + 构图 + 自动调色，全端侧 | 「全端侧」的取舍样本 |
| [`LiveCompose/LiveCompose`](https://github.com/LiveCompose/LiveCompose) | 16 | Python | ⚠️ 无 | ❌ | 唯一「主动引导你移动手机」的 RL 实现（配 LiveCapture iOS 端） | 奖励函数设计与引导策略，**架构参考价值最高** |

其余 4 个 Android 原型（`Ccchen1234/ai-composition-assistant`、`ksesidhar/AstraX`、`MrJanHorak/android-photography-assistant`、`soe-zin/photoassist`）见 [A 类清单](docs/01-direct-overlap.md)，均为 0 星、无许可，仅作形态参考。

---

## 3. 建议的落地路线（和上面的仓库一一对应）

**第 1 期 · 照片构图教练（4–6 周可出 demo）**
`CameraX` 取景 → `MediaPipe Pose` 出人体关键点 → 三分法/中心构图偏差 → 叠加引导框 + 一句短指令 → 达标震动/语音。
拿 `PosePilot` 的姿态管线 + `Shotune` 的提示文案层 + `PHIRA` 的几何计算。
⚠️ 关键坑：**别每秒重算提示**，要做 800ms 最短停留 + 迟滞，否则用户看到的是乱跳的字。

**第 2 期 · 多景别分镜（视频化的第一步）**
一张人像 → 建立/中景/特写三镜头 + 每镜的描述（ShotCrop³ 思路）→ 拍完逐镜校验。
Android 侧用 `Media3 Transformer` 做端侧拼接，`Depth-Anything-Android` 判前后景层次。

**第 3 期 · 实时视频引导（最难，别一上来做）**
把「移动脚步」变成可执行量：需要单目深度 + 平面（地面）估计，算出「再后退 0.8 米」而不是「退一点」。参考 `LiveCompose` 的 RL 奖励 + PhotoGuider 的 measure-then-frame。
预算是硬约束：感知 10–20Hz、决策 1–3Hz、渲染每帧，整体 < 33ms/帧才不掉帧。

---

## 4. 许可与合规（重要，别踩）

- `CameraCompositor`、`PHIRA`、`AI-Camera`、`ai-composition-assistant`、`AstraX`、`LiveCompose` **均无 LICENSE 文件** → 法律上默认「保留所有权利」，**只能读、不能复制进你的代码库**。想用就去开 Issue 问作者要授权。
- 可安全借鉴/改造的只有：`Shotune`（MIT）、`PosePilot`（MIT）、`DevCamera` 类（Apache-2.0）、`Depth-Anything-Android`（Apache-2.0）。
- `J0Nreynolds/AndroidOpenCVCamera` 是 **GPL-3.0**，链接进 App 会传染，慎用。
- 国内上架另需：《个人信息保护法》人脸信息单独同意、CameraX 权限声明、若做云端评分需跨境/境内存储合规。
- 专利 FTO：构图推荐类已有若干美国专利（取景框叠加、自动构图建议），做商业化前建议做一次检索。

---

## 5. 一键拉取（不落库，按需本地克隆）

```powershell
# Windows
pwsh ./scripts/fetch-all.ps1 -Dest D:\src\ai-refs
```

```bash
# macOS / Linux
bash ./scripts/fetch-all.sh ~/src/ai-refs
```

脚本只 clone 不修改，仓库本身保持轻量；上游更新后 `git pull` 即可。

---

## 6. 维护约定

- 星数/活跃度按 **2026-11-23** 快照标注，过期请以链接为准。
- 新增条目必须回答三个问题：**能跑吗（Android）· 有许可吗 · 和本项目哪一层重合**。
- 只收「能验证存在」的仓库，不收营销号列表里的死链。
