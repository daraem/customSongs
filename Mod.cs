using GDWeave;
using csong.Mods;

namespace csong;

public class Mod : IMod {
    public Config Config;

    public Mod(IModInterface modInterface) {
        this.Config = modInterface.ReadConfig<Config>();
        modInterface.Logger.Information("Active");
        modInterface.RegisterScriptMod(new CustomSong());
    }

    public void Dispose() {
        // Cleanup anything you do here
    }
}
