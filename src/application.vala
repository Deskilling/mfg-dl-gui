using Gtk;

namespace Mfg {

public class App : Gtk.Application {
    public App () {
        Object (
            application_id: "dev.deskilling.mfg-dl-gui",
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    protected override void activate () {
        var window = new Window (this);
        window.present ();
    }
}

}
