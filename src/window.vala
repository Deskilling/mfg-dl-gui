using Gtk;

namespace Mfg {

public class Window : Gtk.ApplicationWindow {
    public Window (Gtk.Application app) {
        Object (
            application: app,
            title: "mfg-dl-gui",
            default_width: 900,
            default_height: 600
        );
    }

    construct {
        var label = new Gtk.Label ("mfg") {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
        };

        set_child (label);
    }
}

}
