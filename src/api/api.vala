using Soup;
using Json;

namespace Mfg {

    public class SearchResult {
        public string service         { get; set; }
        public string name            { get; set; }
        public string href            { get; set; }
        public string cover           { get; set; }
        public string description     { get; set; }
        public string production_year { get; set; }
    }

    public class ApiClient : GLib.Object {
        private Soup.Session session;
        private string baseUrl;

        public ApiClient (string baseUrl = "http://localhost:6702") {
            this.baseUrl = baseUrl;
            this.session = new Soup.Session ();
        }

        public async string ? get_async (string path) {
            var msg = new Soup.Message ("GET", baseUrl + path);

            try {
                var stream = yield session.send_async (msg, GLib.Priority.DEFAULT, null);

                if (msg.status_code != 200) {
                    warning ("HTTP %u for %s", msg.status_code, path);
                    return null;
                }

                var data = new DataInputStream (stream);
                var builder = new StringBuilder ();

                string ? line;

                while ((line = yield data.read_line_async (GLib.Priority.DEFAULT, null)) != null) {
                    builder.append (line);
                }

                return builder.str;
            } catch (Error e) {
                warning ("GET failed: %s", e.message);
                return null;
            }
        }

        public async string ? post_async (string path, string json_body) {
            var msg = new Soup.Message ("POST", baseUrl + path);
            var bytes = new GLib.Bytes (json_body.data);
            msg.set_request_body_from_bytes ("application/json", bytes);

            try {
                var stream = yield session.send_async (msg, GLib.Priority.DEFAULT, null);

                var data = new GLib.DataInputStream (stream);
                var builder = new GLib.StringBuilder ();

                string ? line;
                while ((line = yield data.read_line_async (GLib.Priority.DEFAULT, null)) != null) {
                    builder.append (line);
                }

                if (msg.status_code != 200) {
                    warning ("API error %u on %s", msg.status_code, path);
                    return null;
                }
                return builder.str;
            } catch (Error e) {
                warning ("Request failed: %s", e.message);
                return null;
            }
        }

        public async SearchResult[] ? search (string query) {
            var encoded = GLib.Uri.escape_string (query, null, false);
            var body = yield get_async ("/search?q=" + encoded);

            if (body == null) {
                return null;
            }

            var results = new SearchResult[0];
            try {
                var parser = new Json.Parser ();
                parser.load_from_data (body);

                var array = parser.get_root ().get_array ();
                foreach (var i in array.get_elements ()) {
                    var obj = i.get_object ();
                    var r = new SearchResult ();
                    r.service = obj.get_string_member_with_default ("service", "");
                    r.name = obj.get_string_member_with_default ("name", "");
                    r.href = obj.get_string_member_with_default ("href", "");
                    r.cover = obj.get_string_member_with_default ("cover", "");
                    r.description = obj.get_string_member_with_default ("description", "");
                    r.production_year = obj.get_string_member_with_default ("productionYear", "");
                    results += r;
                }
            } catch (Error e) {
                warning ("Failed to parse search results: %s", e.message);
            }
            return results;
        }

    }
}
