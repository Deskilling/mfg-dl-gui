using Adw;

namespace Mfg {
    public class App : Adw.Application {
        public App () {
            Object (
                application_id: "dev.deskilling.mfg-dl-gui",
                flags: GLib.ApplicationFlags.DEFAULT_FLAGS
                );
        }

        protected override void activate () {
            var window = new Window (this);
            window.present ();
        }

    }
}
