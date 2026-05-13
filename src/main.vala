using Gtk;

namespace Mfg {

    public async void saft (string saft) {
        var api = new ApiClient ();

        var results = yield api.search (saft);

        foreach (var r in results) {
            print ("Found: %s (%s)\n", r.name, r.production_year);
        }
    }

    public static int main (string[] args) {
        var loop = new MainLoop ();

        saft.begin ("conan");

        loop.run ();
        return 0;
    }

}
