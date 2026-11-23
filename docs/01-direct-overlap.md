# A 类 · 直接同类项目（Android 构图引导 / 拍摄教练）

> 判定标准：在手机上真的做了「看画面 → 给构图/姿态建议」这件事。
> 全部为个人项目，**没有可直接商用的**；价值在于工程结构与交互取舍。
> 数据快照：2026-11-23（星数来自 GitHub API）。

---

## A1. applekourfeat/CameraCompositor ⭐ 最值得读

| | |
| --- | --- |
| 语言/许可 | Kotlin / **无 LICENSE**（只能读） |
| 活跃度 | 最后推送 2026-11-21，仓库 2026-11-18 建立 |
| Android | ✅ 原生，`artifacts/CameraCompositor-0.14.0-landmarks-debug.apk` 可直接装（Vivo V30 验证） |
| 关键能力 | 主摄离线**自动选景**；短暂遮挡时用地标「窗口回放」保住构图；重力水平仪；主体被裁切时提示换角度；可选 ARCore 深度/在线扫描 |

**为什么它排第一**：这是唯一一个把「自动构图」做成**可安装 APK + 有研究记录**的仓库，而不是 README 画饼。
`research/results/landmark-window-replay.json`、`docs/V0120_LEVEL_AND_SUBJECTS.md` 是少见的「效果数据 + 设计决策」留档。

**可借鉴**
- 自动选景的判定要**跨帧容错**：单帧主体轮廓丢失不等于构图坏了，用几百毫秒的窗口做平滑。
- 「水平仪」是低成本高感知的功能，实现便宜、用户立刻有感——优先做。
- 用 `artifacts/` 放 APK、用 `docs/` 放决策记录，是个人项目很好的工程习惯。

**别学**：README 自述「UI/UX 还没做」，说明它仍是实验室产品；没有 license，任何代码复制都有风险。

---

## A2. gleikeen/Shotune ⭐ 设计最完整（MIT）

| | |
| --- | --- |
| 语言/许可 | Kotlin / **MIT**（可安全借鉴） |
| 活跃度 | 4★，最后推送 2026-03-10 |
| Android | ⚠️ **仓库目前只有实施文档**（`shotune-camera-app-plan.md` + `backend/`），没有可跑的 App |
| 定位 | 前摄自拍闭环：每秒抽帧 → 本地姿态/构图 → 云端审美评分 → 短句提示 → 达标后**仍由用户手动按快门** |

**价值**：`shotune-camera-app-plan.md` 基本是一份现成 PRD，把「门控抽帧 → 本地轻模型 → 云端重模型 → 参数微调 → 会话记录」这条链路讲清楚了。
特别是三个设计决策值得直接采纳：
1. **每秒抽一帧**而非逐帧推理——省电、够用；
2. 先做**质量门控**（亮度/模糊/重复帧）再送评分，避免无效请求；
3. **不做自动快门**，只在 Ready 状态提醒——用户信任成本最低的折中。

**风险**：文档超前于代码，别指望 clone 下来能跑。

---

## A3. sourishnandy4-cell/PosePilot ⭐ 唯一能直接跑的姿态引导（MIT）

| | |
| --- | --- |
| 语言/许可 | Kotlin / **MIT**，MediaPipe 0.10.14，Kotlin 2.0.20，minSdk 24 |
| 活跃度 | 1★，最后推送 2026-07-12 |
| 平台 | Android（`app/`）+ iOS（`ios/`）双端 |
| 能力 | 实时体态教练：站直、肩膀水平、构图居中，语音/文字提示 |

**用途**：如果你要最快验证「实时姿态 → 语言提示」这条链路，这是最短路径。
MediaPipe 0.10.14 的 Tasks API + CameraX 组合，代码量小，MIT 可商用改造。

**局限**：只有「人」的引导，没有景物层次/焦段/脚步距离；美学判断缺失。

---

## A4. Yansyah0209/PHIRA

| | |
| --- | --- |
| 语言/许可 | Kotlin / **无 LICENSE** |
| 活跃度 | 0★，最后推送 2026-10-09，Android 10+ |
| 能力 | 以黄金比例 φ 为核心的实时构图引导；三种网格；GitHub Actions 直接产出 debug APK |

**可借鉴**：`core/` 与 `app/` 分模块（构图几何可单测）；Actions 出 APK 的分发方式对个人项目很实用。
**注意**：无许可，代码不可复制。

---

## A5. clifftseng/AI-Camera

Kotlin / 无许可 / 0★ / 2026-08-19。姿态引导 + 构图 + **自动调色**，宣称全端侧。
价值在于「全端侧」的取舍样本（没有云端兜底时，模型得多小、提示得多保守）。

## A6. Ccchen1234/ai-composition-assistant

Kotlin / 无许可 / 0★ / 2026-05-07。Android 智能构图助手，功能描述最接近你的设想，但代码量与完成度最低。

## A7. ksesidhar/AstraX

Kotlin / 无许可 / 0★ / 2026-06-16。面向初学者的 AI 相机，含拍摄教学。参考交互即可。

## A8. 边缘相关（非构图，但同场景）

- `MrJanHorak/android-photography-assistant`（Kotlin，无许可）——摄影师工具箱式实验。
- `soe-zin/photoassist`（Kotlin，无许可）——摄影助手 App。

---

## A9. 非 Android 但绕不开：LiveCompose / LiveCapture

| | |
| --- | --- |
| `LiveCompose/LiveCompose` | Python，16★，无许可。RL 训练 + 陀螺仪，**主动引导用户移动手机**去获得更好构图 |
| `LiveCompose/LiveCapture` | Swift + Core ML，11★，无许可。iOS 端实时推理 |

这是**唯一**把「引导移动」做成学习型策略的公开实现。
它证明了两件事：① 端侧可以跑得动；② 用 RL 学「往哪走」比规则引导更自然——但也更难调、更难解释。
如果你要做第 3 期（实时移动引导），它的奖励函数是必读；工程上别照搬到 Android，重写成本低于移植。

---

## 汇总对比

| 仓库 | 星 | 许可 | 能跑 | 完整度 | 借鉴价值 |
| --- | --- | --- | --- | --- | --- |
| CameraCompositor | 0 | 无 | ✅ APK | 高 | ★★★★★ |
| Shotune | 4 | MIT | ❌ 文档 | 低 | ★★★★（PRD） |
| PosePilot | 1 | MIT | ✅ | 中 | ★★★★（可改） |
| PHIRA | 0 | 无 | ✅ | 中 | ★★★ |
| AI-Camera | 0 | 无 | ✅ | 低 | ★★ |
| ai-composition-assistant | 0 | 无 | ⚠️ | 低 | ★★ |
| AstraX | 0 | 无 | ⚠️ | 低 | ★★ |
| LiveCompose | 16 | 无 | ❌ | 研究级 | ★★★★★（算法） |
