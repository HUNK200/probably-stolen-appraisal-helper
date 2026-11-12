using System;

namespace ProbablyStolen.AppraisalHelper
{
    /// <summary>
    /// 模组入口。游戏从 manifest.xml 读取元数据，解析成 ModManifest 后传入 Init。
    /// 生命周期：Init → OnEnable（都在主菜单阶段）→ …… → OnDisable（退出游戏时）。
    /// 注意：这个阶段还没有存档、没有商店容器、没有游戏管理器，不要在这里访问游戏状态。
    /// </summary>
    public sealed class ModEntry : IMod
    {
        /// <summary>给其它类用的日志入口。</summary>
        internal static ModLog Log { get; private set; }

        private ModManifest _manifest;

        public void Init(ModManifest manifest)
        {
            _manifest = manifest;
            Log = new ModLog(manifest);
            Log.Log("AppraisalHelper 已加载（Init）");
        }

        public void OnEnable()
        {
            Log.Log("AppraisalHelper 已启用（OnEnable），开始订阅钩子");
            ModHook.OnGameLoadedNormal += OnGameLoaded;
        }

        public void OnDisable()
        {
            ModHook.OnGameLoadedNormal -= OnGameLoaded;
            Log.Log("AppraisalHelper 已停用（OnDisable）");
        }

        /// <summary>
        /// 存档载入完成。这一步能安全访问游戏对象，后面 R01 的检索逻辑就从这里开始接。
        /// </summary>
        private void OnGameLoaded()
        {
            Log.Log("检测到存档载入完成，游戏对象可用");
        }
    }
}
