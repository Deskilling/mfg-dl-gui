using Gtk;

namespace Mfg {

    public async void saft (string saft) {
        var api = new ApiClient ();

        var results = yield api.search (saft);

        foreach (var r in results) {
            print ("Found: %s (%s)\n", r.name, r.production_year);
        }

        var show = yield api.searchSite (results[0].name, "Aniworld");

        var seasons = yield api.season (show[0]);

        foreach (var r in seasons) {
            print ("Season: %s\n", r.seasonLabel);
        }

        var episodes = yield api.epiosdes (seasons[1]);

        foreach (var r in episodes) {
            print ("Epiosde: %s\n", r.episodeTitle);

        }

    }

    public static int main (string[] args) {
        var loop = new MainLoop ();

        saft.begin ("rascal");

        loop.run ();
        return 0;
    }

}
