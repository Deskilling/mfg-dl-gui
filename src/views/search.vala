using Gtk;
using Adw;

namespace Mfg {

    public class ResultCard : Gtk.Box {
        public SearchResult result;
        private Gtk.Picture picture;

        public ResultCard (SearchResult r, ApiClient api) {
            Object (orientation: Gtk.Orientation.VERTICAL, spacing: 0);
            this.result = r;

            add_css_class ("card");

            overflow = Gtk.Overflow.HIDDEN;
            var overlay = new Gtk.Overlay () {
                vexpand = true,
                hexpand = true
            };

            picture = new Gtk.Picture () {
                content_fit = Gtk.ContentFit.COVER,
                can_shrink = true,
                halign = Gtk.Align.FILL,
                valign = Gtk.Align.FILL,
            };
            overlay.set_child (picture);

            loadCover.begin (r, api);
            append (overlay);

            var info = new Gtk.Box (Gtk.Orientation.VERTICAL, 2) {
                margin_start = 8,
                margin_end = 8,
                margin_top = 6,
                margin_bottom = 8,
                halign = Gtk.Align.START,
            };
            info.add_css_class ("card-overlay-info");

            var title = new Gtk.Label (r.name) {
                xalign = 0,
                wrap = true,
                lines = 2,
                ellipsize = Pango.EllipsizeMode.END,
                halign = Gtk.Align.START
            };
            title.add_css_class ("caption-heading");

            info.append (title);
            var year = new Gtk.Label (r.production_year) {
                xalign = 0,
                halign = Gtk.Align.START
            };

            year.add_css_class ("caption");
            year.add_css_class ("dim-label");
            info.append (year);
            append (info);
        }

        private async void loadCover (SearchResult r, ApiClient api) {
            if (r.cover == null || r.cover == "") {
                return;
            }
            try {
                string ? coverpath = yield api.cover (r);

                if (coverpath == null) {
                    return;
                }

                var texture = Gdk.Texture.from_filename (coverpath);
                picture.set_paintable (texture);
            } catch (Error e) {
                warning ("Failed to load cover: %s", e.message);
            }
        }

    }

    public class SearchPage : Adw.NavigationPage {
        private ApiClient api;
        private Gtk.SearchEntry search_entry;
        private Gtk.FlowBox flow;

        public SearchPage () {
            Object (title: "Search");
        }

        construct {
            api = new ApiClient ();

            var header = new Adw.HeaderBar ();
            header.title_widget = new Adw.WindowTitle ("mfg-dl", "");

            var search_clamp = new Adw.Clamp () {
                maximum_size = 560,
                margin_top = 10,
                margin_bottom = 10,
                margin_start = 16,
                margin_end = 16
            };

            search_entry = new Gtk.SearchEntry () {
                placeholder_text = "Search…",
            };

            search_entry.activate.connect (on_search);
            search_clamp.set_child (search_entry);

            flow = new Gtk.FlowBox () {
                homogeneous = true,
                column_spacing = 12,
                row_spacing = 12,
                // TODO fix this so it scales with the window
                max_children_per_line = -1,
                min_children_per_line = 6,
                selection_mode = Gtk.SelectionMode.NONE,
                activate_on_single_click = true,

                margin_start = 16,
                margin_end = 16,
                margin_top = 12,
                margin_bottom = 16,

                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.START
            };

            flow.child_activated.connect (on_click);

            var scroll = new Gtk.ScrolledWindow () {
                vexpand = true,
                hscrollbar_policy = Gtk.PolicyType.NEVER
            };

            scroll.set_child (flow);

            var body = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            body.append (search_clamp);
            body.append (scroll);

            var toolbar = new Adw.ToolbarView ();
            toolbar.add_top_bar (header);
            toolbar.set_content (body);

            set_child (toolbar);
        }

        private void clear_results () {
            var child = flow.get_first_child ();
            while (child != null) {
                var next = child.get_next_sibling ();
                flow.remove (child);
                child = next;
            }
        }

        private void on_search () {
            var query = search_entry.text.strip ();
            if (query == "") {
                return;
            }

            clear_results ();
            do_search.begin (query);
        }

        private async void do_search (string query) {
            var results = yield api.search (query);

            if (results == null || results.length == 0) {
                return;
            }

            foreach (var r in results) {
                flow.append (new ResultCard (r, api));
            }
        }

        private void on_click (Gtk.FlowBoxChild child) {
            var card = child.get_child () as ResultCard;
            if (card == null) {
                return;
            }
        }

    }
}
