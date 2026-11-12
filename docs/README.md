# docs/ 索引

技术调研与验证记录。需求本身看根目录的 [`project.md`](../project.md)，工程约定看 [`AGENTS.md`](../AGENTS.md)。

| 文档 | 内容 | 状态 |
| --- | --- | --- |
| [`mod-api-notes.md`](mod-api-notes.md) | 原生 Mod API 速查：包结构、manifest、生命周期、钩子、纸质手册系统、鉴定 API、构建方式、仍待确认项 | 依据社区指南整理；`IMod` 等签名已用编译验证 |
| [`prototype-01-vanilla-manual.md`](prototype-01-vanilla-manual.md) | 原型验证 01：只用原版手册观察面板行为（零代码、零安装） | **已完成**（100-REV13） |
| [`build-and-deploy.md`](build-and-deploy.md) | 编译与部署的可复现步骤：环境、游戏路径、编译、部署、启用、看日志、卸载 | **可用** |
| [`prototype-02-self-book.md`](prototype-02-self-book.md) | 原型验证 02：自制手册能否稳定停在左侧（`posX/posY`） | **进行中**；编辑器不写位置字段，待手工验证 |


## 阅读顺序

1. 想弄清「这个 Mod 到底怎么做」→ `mod-api-notes.md`
2. 想知道「现在卡在哪、下一步干嘛」→ `prototype-01-vanilla-manual.md`

## 记录约定

- 调研类文档要写清**来源**和**可信度**（社区 / 官方 / 实机）。
- 实机验证过的结论，把「待确认」标记改成明确结论，并注明**游戏版本串**。
- 推翻了旧结论时，保留一行「更正记录」说明改了什么、为什么，不要直接删掉旧内容。
