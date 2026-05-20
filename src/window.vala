using Gtk;
using Adw;

namespace Mfg {
    public class Window : Adw.ApplicationWindow {
        public Window (Adw.Application app) {
            Object (
                application: app,
                title: "mfg-dl-gui",
                default_width: 860,
                default_height: 640
                );
        }

        construct {
            var search_page = new SearchPage ();

            var nav = new Adw.NavigationView ();
            nav.add (search_page);

            set_content (nav);
        }
    }
}
