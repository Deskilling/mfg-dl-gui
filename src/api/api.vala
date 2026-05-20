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

    public class Season {
        public string service { get; set; }
        public string name { get; set; }
        public string href  { get; set; }
        public string seasonNum { get; set; }
        public string seasonLabel { get; set; }
    }

    public class Episode {
        public string service { get; set; }
        public string name { get; set; }
        public string href  { get; set; }
        public string seasonNum { get; set; }
        public string episodeTitle { get; set; }
        public string episodeAlternativeTitle { get; set; }
        public string episodeNum { get; set; }
    }

    public class Stream {
        public string service { get; set; }
        public string name { get; set; }
        public string href  { get; set; }
        public string seasonNum { get; set; }
        public string episodeTitle { get; set; }
        public string episodeAlternativeTitle { get; set; }
        public string episodeNum { get; set; }
        public string hoster { get; set; }
        public string language { get; set; }
    }

    public class ApiClient : GLib.Object {
        public Soup.Session session;
        private string baseUrl;

        public ApiClient (string baseUrl = "http://localhost:6702") {
            this.baseUrl = baseUrl;
            this.session = new Soup.Session ();
        }

        public async string ? post_async (string path, string json_body) {
            var msg = new Soup.Message ("POST", baseUrl + path);
            var bytes = new GLib.Bytes (json_body.data);
            msg.set_request_body_from_bytes ("application/json", bytes);

            message ("Sending POST message to: \n%s", baseUrl + path);

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
            var body = yield post_async ("/search?q=" + encoded, "");

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

        public async SearchResult[] ? searchSite (string query, string service) {
            var encoded = GLib.Uri.escape_string (query, null, false);
            var body = yield post_async ("/searchsite?q=" + encoded + "&service=" + service, "");

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

        public async string ? cover (SearchResult result) {
            var builder = new Json.Builder ();

            builder.begin_object ();

            builder.set_member_name ("service");
            builder.add_string_value ("Aniworld");

            builder.set_member_name ("name");
            builder.add_string_value (result.name);

            builder.set_member_name ("href");
            builder.add_string_value (result.href);

            builder.set_member_name ("cover");
            builder.add_string_value (result.cover);

            builder.set_member_name ("description");
            builder.add_string_value (result.description);

            builder.set_member_name ("production_year");
            builder.add_string_value (result.production_year);

            builder.end_object ();

            var generator = new Json.Generator ();
            generator.pretty = true;
            generator.set_root (builder.get_root ());

            string json_body = generator.to_data (null);

            message ("Season request JSON:\n%s", json_body);

            var body = yield post_async ("/cover", json_body);

            if (body == null) {
                warning ("No response from /cover");
                return null;
            }

            message ("Season response JSON:\n%s", body);
            return body.to_string ();
        }

        public async Season[] ? season (SearchResult result) {
            var builder = new Json.Builder ();

            builder.begin_object ();

            builder.set_member_name ("service");
            builder.add_string_value ("Aniworld");

            builder.set_member_name ("name");
            builder.add_string_value (result.name);

            builder.set_member_name ("href");
            builder.add_string_value (result.href);

            builder.set_member_name ("cover");
            builder.add_string_value (result.cover);

            builder.set_member_name ("description");
            builder.add_string_value (result.description);

            builder.set_member_name ("production_year");
            builder.add_string_value (result.production_year);

            builder.end_object ();

            var generator = new Json.Generator ();
            generator.pretty = true;
            generator.set_root (builder.get_root ());

            string json_body = generator.to_data (null);

            message ("Season request JSON:\n%s", json_body);

            var body = yield post_async ("/seasons", json_body);

            if (body == null) {
                warning ("No response from /seasons");
                return null;
            }

            message ("Season response JSON:\n%s", body);

            var seasons = new Season[0];

            try {
                var parser = new Json.Parser ();
                parser.load_from_data (body);

                var root = parser.get_root ();

                Json.Array array;
                array = root.get_array ();


                foreach (var el in array.get_elements ()) {
                    var obj = el.get_object ();

                    seasons += new Season () {
                        service = obj.get_string_member_with_default ("service", ""),
                        name = obj.get_string_member_with_default ("name", ""),
                        href = obj.get_string_member_with_default ("href", ""),
                        seasonNum = obj.get_string_member_with_default ("seasonNum", ""),
                        seasonLabel = obj.get_string_member_with_default ("seasonLabel", "")
                    };
                }

            } catch (Error e) {
                warning ("Failed to parse seasons: %s", e.message);
                return null;
            }

            return seasons;
        }

        public async Episode[] ? epiosdes (Season season) {
            var builder = new Json.Builder ();

            builder.begin_object ();

            builder.set_member_name ("service");
            builder.add_string_value ("Aniworld");

            builder.set_member_name ("name");
            builder.add_string_value (season.name);

            builder.set_member_name ("href");
            builder.add_string_value (season.href);

            builder.set_member_name ("seasonnum");
            builder.add_string_value (season.seasonNum);

            builder.set_member_name ("seasonlabel");
            builder.add_string_value (season.seasonLabel);

            builder.end_object ();

            var generator = new Json.Generator ();
            generator.pretty = true;
            generator.set_root (builder.get_root ());

            string json_body = generator.to_data (null);

            message ("Episode request JSON:\n%s", json_body);

            var body = yield post_async ("/episodes", json_body);

            if (body == null) {
                warning ("No response from /episodes");
                return null;
            }

            message ("Episode response JSON:\n%s", body);

            var episodes = new Episode[0];

            try {
                var parser = new Json.Parser ();
                parser.load_from_data (body);

                var root = parser.get_root ();

                Json.Array array;
                array = root.get_array ();


                foreach (var el in array.get_elements ()) {
                    var obj = el.get_object ();

                    episodes += new Episode () {
                        service = obj.get_string_member_with_default ("service", ""),
                        name = obj.get_string_member_with_default ("name", ""),
                        href = obj.get_string_member_with_default ("href", ""),
                        seasonNum = obj.get_string_member_with_default ("seasonNum", ""),
                        episodeNum = obj.get_string_member_with_default ("episodeNum", ""),
                        episodeTitle = obj.get_string_member_with_default ("episodeTitle", ""),
                        episodeAlternativeTitle = obj.get_string_member_with_default ("episodeAlternativeTitle", ""),
                    };
                }

            } catch (Error e) {
                warning ("Failed to parse episodes: %s", e.message);
                return null;
            }

            return episodes;
        }

        public async Stream[] ? stream (Episode episode) {
            var builder = new Json.Builder ();

            builder.begin_object ();

            builder.set_member_name ("service");
            builder.add_string_value ("Aniworld");

            builder.set_member_name ("name");
            builder.add_string_value (episode.name);

            builder.set_member_name ("href");
            builder.add_string_value (episode.href);

            builder.set_member_name ("seasonnum");
            builder.add_string_value (episode.seasonNum);

            builder.set_member_name ("episodenum");
            builder.add_string_value (episode.episodeNum);

            builder.set_member_name ("episodetitle");
            builder.add_string_value (episode.episodeTitle);

            builder.set_member_name ("episodealternativetitle");
            builder.add_string_value (episode.episodeAlternativeTitle);

            builder.end_object ();

            var generator = new Json.Generator ();
            generator.pretty = true;
            generator.set_root (builder.get_root ());

            string json_body = generator.to_data (null);

            message ("Streams request JSON:\n%s", json_body);

            var body = yield post_async ("/streams", json_body);

            if (body == null) {
                warning ("No response from /streams");
                return null;
            }

            message ("Streams response JSON:\n%s", body);

            var streams = new Stream[0];

            try {
                var parser = new Json.Parser ();
                parser.load_from_data (body);

                var root = parser.get_root ();

                Json.Array array;
                if (root.get_node_type () == Json.NodeType.ARRAY) {
                    array = root.get_array ();
                } else {
                    var obj = root.get_object ();
                    array = obj.get_array_member ("seasons");
                }

                foreach (var el in array.get_elements ()) {
                    var obj = el.get_object ();

                    streams += new Stream () {
                        service = obj.get_string_member_with_default ("service", ""),
                        name = obj.get_string_member_with_default ("name", ""),
                        href = obj.get_string_member_with_default ("href", ""),
                        seasonNum = obj.get_string_member_with_default ("seasonNum", ""),
                        episodeNum = obj.get_string_member_with_default ("episodeNum", ""),
                        episodeTitle = obj.get_string_member_with_default ("episodeTitle", ""),
                        episodeAlternativeTitle = obj.get_string_member_with_default ("episodeAlternativeTitle", ""),
                        language = obj.get_string_member_with_default ("language", ""),
                        hoster = obj.get_string_member_with_default ("hoster", ""),
                    };
                }

            } catch (Error e) {
                warning ("Failed to parse episodes: %s", e.message);
                return null;
            }

            return streams;
        }

        public async void download (Stream stream) {
            var builder = new Json.Builder ();

            builder.begin_object ();

            builder.set_member_name ("service");
            builder.add_string_value ("Aniworld");

            builder.set_member_name ("name");
            builder.add_string_value (stream.name);

            builder.set_member_name ("href");
            builder.add_string_value (stream.href);

            builder.set_member_name ("seasonnum");
            builder.add_string_value (stream.seasonNum);

            builder.set_member_name ("episodenum");
            builder.add_string_value (stream.episodeNum);

            builder.set_member_name ("episodetitle");
            builder.add_string_value (stream.episodeTitle);

            builder.set_member_name ("episodealternativetitle");
            builder.add_string_value (stream.episodeAlternativeTitle);

            builder.set_member_name ("language");
            builder.add_string_value (stream.language);

            builder.set_member_name ("hoster");
            builder.add_string_value (stream.hoster);

            builder.end_object ();

            var generator = new Json.Generator ();
            generator.pretty = true;
            generator.set_root (builder.get_root ());

            string json_body = generator.to_data (null);

            message ("Download request JSON:\n%s", json_body);

            var body = yield post_async ("/download", json_body);

            if (body == null) {
                warning ("No response from /download");
                return;
            }

            message ("Download response JSON:\n%s", body);

            // TODO Parse the Repsonse
        }

    }
}
