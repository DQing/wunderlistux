using Gtk;
using Soup;
using WebKit;


public class DorisConfig {
	const string home_dir_subdir = ".doris";

	public static string get_dir() {
		return Path.build_filename(GLib.Environment.get_variable("HOME"), home_dir_subdir);
	}

	public static string get_path(string file) {
		return Path.build_filename(GLib.Environment.get_variable("HOME"), home_dir_subdir, file);
	}
}


public class Wunderlistux :  Window {

    // private const string TITLE = "Wunderlistux";
    private const string HOME_URL = "https://www.wunderlist.com/webapp";
    private const string DEFAULT_PROTOCOL = "https";

    private Regex protocol_regex;

    // private Entry url_bar;
    private WebView web_view;
    // private Label status_bar;
    private ToolButton notifications_button;
    private ToolButton conversations_button;

    private ToolButton sort_button;
    private ToolButton share_button;
    private ToolButton more_button;
    private string home_subdir;

    public Wunderlistux () {
        // this.title = Wunderlistux.TITLE;
        this.title = "Wunderlist";
        set_default_size (800, 600);

        try {
            this.protocol_regex = new Regex (".*://.*");
        } catch (RegexError e) {
            critical ("%s", e.message);
        }

        create_widgets ();
        connect_signals ();
        // this.url_bar.grab_focus ();
    }

    private void create_widgets () {
        // var toolbar = new Toolbar ();
        this.notifications_button = new ToolButton(null, null);//.from_stock (Stock.SORT_ASCENDING);

		    Image img = new Image.from_icon_name ("notification-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        this.notifications_button.set_icon_widget (img);
        this.conversations_button = new ToolButton(null, null);//.from_stock (Stock.SORT_DESCENDING);
        img = new Image.from_icon_name ("media-view-subtitles-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        this.conversations_button.set_icon_widget (img);
        this.sort_button = new ToolButton(null, null);//.from_stock (Stock.PROPERTIES);
        img = new Image.from_icon_name ("view-sort-ascending-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        this.sort_button.set_icon_widget (img);//.set_icon_name("view-sort-ascending-symbolic");
        this.more_button = new ToolButton(null, null);
        img = new Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        this.more_button.set_icon_widget (img);//.set_icon_name("view-more-symbolic");
        this.share_button = new ToolButton(null, null);
        img = new Image.from_icon_name ("contact-new-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        this.share_button.set_icon_widget (img);//.set_icon_name("contact-new-symbolic");
        // toolbar.add (this.notifications_button);
        // toolbar.add (this.conversations_button);
        // toolbar.add (this.sort_button);
        // this.url_bar = new Entry ();

				// Create the window of this application and show it
				// Gtk.ApplicationWindow window = new Gtk.ApplicationWindow (this);
				this.set_default_size (550, 680);
				// window.window_position = WindowPosition.CENTER;
				// window.set_border_width(10);

        this.web_view = new WebView ();
        this.home_subdir = DorisConfig.get_dir();
		    DirUtils.create(this.home_subdir, 0700);

        this.web_view.web_context.get_cookie_manager().set_persistent_storage(Path.build_filename(this.home_subdir, "cookies.txt"), WebKit.CookiePersistentStorage.TEXT);


        var scrolled_window = new ScrolledWindow (null, null);
        scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolled_window.add (this.web_view);
        // this.status_bar = new Label ("Welcome");
        // this.status_bar.xalign = 0;



				// add headerbar with button
				Gtk.HeaderBar headerbar = new Gtk.HeaderBar();
        headerbar.show_close_button = true;
        var box = new Box (Orientation.HORIZONTAL, 3);
        // headerbar.title = "Window";
				box.add(this.notifications_button);
				box.add(this.conversations_button);

        var group_box = new Box (Orientation.HORIZONTAL, 3);
        group_box.pack_start (this.sort_button, false, false, 0);
        group_box.pack_end (this.share_button, false, false, 0);
        group_box.pack_end (this.more_button, false, false, 0);

				// headerbar.add(this.sort_button);
        // headerbar.add(this.share_button);
        // headerbar.add(this.more_button);


        this.set_titlebar(headerbar);


        var vbox = new VBox (false, 0);
        // vbox.pack_start (toolbar, false, true, 0);
        // vbox.pack_start (this.url_bar, false, true, 0);
				// vbox.add (window);
				vbox.add (scrolled_window);





        headerbar.pack_start(box);
        headerbar.pack_end(group_box);

        // vbox.pack_start (this.status_bar, false, true, 0);
				// vbox.pack_start (this.status_bar, false, true, 0);
        add (vbox);
    }

    public void load_styles(){
      var style = "#user-toolbar .stream-counts{ position: absolute!important; top: -5%!important; left: 47%!important; } #list-toolbar{ position: absolute!important; top: -48px!important; right: 32px!important; } .popover{ left: 20px!important; top: 4px!important; } #wunderlist-base .popover.bottom .arrow{ display: none!important; }";
      var script = "jQuery('#window_theme_container').remove(); ";
      script = script + "jQuery('<style id=\"window_theme_container\">"+ style +"</style>').appendTo('body');";
      // script = "var onLoaded = function(){ "+script+"; console.error('executed!') };";
      // script = script + " onLoaded(); ";
      // script = script + " jQuery.wait = function(ms) { var defer = jQuery.Deferred(); setTimeout(function() { defer.resolve(); }, ms); return defer;   }; jQuery.wait(100).then(onLoaded); jQuery.wait(1000).then(onLoaded); jQuery.wait(6000).then(onLoaded); jQuery.wait(15000).then(onLoaded);";
      this.web_view.run_javascript(script, null);
    }

    private void connect_signals () {
        this.destroy.connect (Gtk.main_quit);
        // this.url_bar.activate.connect (on_activate);
        // this.web_view.load_changed.connect (load_styles);
        // this.web_view.ready_to_show.connect (load_styles);
        this.web_view.resource_load_started.connect (load_styles);
        // load_styles();

        this.conversations_button.clicked.connect ((args) => {
          this.web_view.run_javascript("jQuery('[data-path=\"conversations\"]').click()", null);
        });
        this.notifications_button.clicked.connect ((args) => {
          this.web_view.run_javascript("jQuery('[data-path=\"activities\"]').click()", null);
        });
        this.share_button.clicked.connect ((args) => {
          this.web_view.run_javascript("jQuery('[data-menu=\"share\"]').click()", null);
        });
        this.sort_button.clicked.connect ((args) => {
          this.web_view.run_javascript("jQuery('[data-menu=\"sort\"]').click()", null);
        });
        this.more_button.clicked.connect ((args) => {
          this.web_view.run_javascript("jQuery('[data-menu=\"more\"]').click()", null);
        });

        // this.conversations_button.clicked.connect (this.web_view.go_forward);
        // this.sort_button.clicked.connect (this.web_view.reload);
    }

    // private void update_buttons () {
        // this.notifications_button.sensitive = this.web_view.can_go_back ();
        // this.conversations_button.sensitive = this.web_view.can_go_forward ();
    // }

    // private void on_activate () {
        // var url = this.url_bar.text;
        // if (!this.protocol_regex.match (url)) {
        //     url = "%s://%s".printf (Wunderlistux.DEFAULT_PROTOCOL, url);
        // }
        // this.web_view.open (url);
    // }

    public void start () {
        show_all ();
        this.web_view.load_uri (Wunderlistux.HOME_URL);
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        var browser = new Wunderlistux ();
        browser.start ();

        Gtk.main ();

        return 0;
    }
}