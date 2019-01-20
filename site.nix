/*-----------------------------------------------------------------------------
   Init

   Initialization of Styx, should not be edited
-----------------------------------------------------------------------------*/
{ styx
, extraConf ? {}
, pkgs ? import ./nixpkgs.nix {}
, fractalide-src ? pkgs.fetchFromGitHub {
    owner = "fractalide"; repo = "fractalide";
    rev = "8b5f020895612d17dcf86f20115c14fa845a79e4";
    sha256 = "1jbbmnrgyi4245imixfs8slgw3kdp7li8dhfy84d4snw239z5dpj";
  }
, changelog ? builtins.fromJSON (builtins.readFile "${fractalide-src}/CHANGELOG.json")
, liveConf ? pkgs.callPackage <fractalide-com-config> {}
}:

rec {

  /* Importing styx library
  */
  styxLib = import styx.lib styx;


/*-----------------------------------------------------------------------------
   Themes setup

-----------------------------------------------------------------------------*/

  /* Importing styx themes from styx
  */
  styx-themes = import styx.themes;

  /* list the themes to load, paths or packages can be used
     items at the end of the list have higher priority
  */
  themes = [
    styx-themes.generic-templates
    ./themes/fractalide
    ./themes/fractalide-site
  ];

  /* Loading the themes data
  */
  themesData = styxLib.themes.load {
    inherit styxLib themes;
    extraEnv = { inherit data pages; };
    extraConf = [ ./conf.nix extraConf ];
  };

  /* Bringing the themes data to the scope
  */
  inherit (themesData) conf lib files templates env;


/*-----------------------------------------------------------------------------
   Data

   This section declares the data used by the site
-----------------------------------------------------------------------------*/

  data = {
    blog = lib.sortBy "date" "dsc" (lib.loadDir { dir = ./data/blog; inherit env; });
    inherit changelog;
    nav = import ./data/nav.nix { inherit pages templates; };
    site-partials = lib.loadDir { dir = ./data/site-partials; inherit env; asAttrs = true; };
    team = lib.loadDir { dir = ./data/team; };
    faqs = import ./data/faqs.nix;
  };

/*-----------------------------------------------------------------------------
   Pages

   This section declares the pages that will be generated
-----------------------------------------------------------------------------*/

  pages = let site-partials = data.site-partials; in rec {
    contact = rec {
      path     = "/contact/index.html";
      template = templates.block-page.full;
      layout   = templates.layout;
      blocks   = [ content ];
      content  = lib.loadFile { file = ./content/contact.md; env = {}; };
    };

    documentation = rec {
      title    = "Documentation";
      path     = "/documentation/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = builtins.readFile (
        pkgs.runCommand "doc-index" {
          buildInputs = [ pkgs.styx ];
          allowSubstitutes = false;
          src = fractalide-src;
        } ''
          asciidoctor -b xhtml5 -s -a showtitle -o- $src/doc/index.adoc > $out
        ''
      );
      footer   = "";
    };

    index = rec {
      path     = "/index.html";
      template = templates.block-page.full;
      layout   = templates.layout;
      blocks   = [ content ];
      content  = lib.loadFile { file = ./content/index.md; env = { inherit (data) site-partials; }; };
    };

    research = rec {
      title    = "Research";
      section  = "research";
      path     = "/research/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = (lib.loadFile { file = ./content/research.md; }).content;
      footer   = "";
    };

    community = rec {
      title    = "Community";
      section  = "community";
      path     = "/community/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = (lib.loadFile { file = ./content/community.md; }).content;
      footer   = "";
    };

    roadmap = rec {
      path     = "/roadmap/index.html";
      template = templates.block-page.full;
      layout   = templates.layout;
      blocks   = [ content ];
      content  = lib.loadFile { file = ./content/roadmap.md; env = {
        inherit lib;
        inherit (data) changelog;
      }; };
    };

    sitemap = {
      path     = "/sitemap.xml";
      template = templates.sitemap;
      layout   = lib.id;
      pages    = lib.pagesToList { inherit pages; };
    };

    luceo = rec {
      title    = "Luceo (CEO)";
      section  = "luceo";
      path     = "/luceo/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = (lib.loadFile { file = ./content/luceo.md; }).content;
      extraContent = site-partials.signup.content;
    };

    gift = rec {
      title    = "";
      section  = "luceo-ceo";
      path     = "/gift/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = (lib.loadFile { file = ./content/gift.md; }).content;
      extraContent = site-partials.signup.content;
    };

    stake-pool-overview = rec {
      title    = "Stakepools";
      section  = "stakepools";
      path     = "/stake-pool/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = (lib.loadFile { file = ./content/stake-pool/overview.md; }).content;
      extraContent = site-partials.signup.content;
    };

    stake-pool-luceo-ceo = rec {
      title    = "";
      section  = "luceo-ceo";
      path     = "/stake-pool/luceo-ceo/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = (lib.loadFile { file = ./content/stake-pool/luceo-ceo.md; }).content;
      extraContent = site-partials.signup.content;
    };

    stake-pool-cardano-ada = rec {
      title    = "";
      section  = "cardano-ada";
      path     = "/stake-pool/cardano-ada/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = (lib.loadFile { file = ./content/stake-pool/cardano-ada.md; }).content;
      extraContent = site-partials.signup.content;
    };

    stake-pool-tezos-xtz = rec {
      title    = "";
      section  = "tezos-xtz";
      path     = "/stake-pool/tezos-xtz/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = (lib.loadFile {
        file = ./content/stake-pool/tezos-xtz.md;
        env = {
          inherit (liveConf.stakepool.xtz) address data;
          inherit lib;
        };
      }).content;
      extraContent = site-partials.signup.content;
    };

    cantor-wallet = rec {
      title    = "Cantor Wallet";
      hideTitle = true;
      section  = "cantor";
      path     = "/cantor-wallet/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = sections.cantor-wallet.content;
      extraContent = sections.download_center.content;
      sections = lib.loadDir {
        dir = ./content/cantor-wallet;
        asAttrs = true;
      };
      inherit (data) site-partials;
    };

    trulity = rec {
      title    = "Trulity";
      section  = "trulity";
      path     = "/trulity/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = sections.trulity.content;
      extraContent = sections.trulity_modes.content + site-partials.signup.content;
      sections = lib.loadDir { dir = ./content/trulity; asAttrs = true; };
      inherit (data) site-partials;
    };

    mercat = rec {
      title    = "Mercat Cross";
      section  = "mercat";
      path     = "/mercat/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = sections.mercat.content;
      extraContent = sections.mercat_dapps.content + site-partials.signup.content;
      sections = lib.loadDir { dir = ./content/mercat; asAttrs = true; };
    };

    blogIndex = lib.mkSplit {
      basePath     = "/blog/index";
      title        = "Blog";
      template     = templates.blog.index;
      layout       = templates.layout;
      itemsPerPage = conf.theme.blog.index.itemsPerPage;
      data         = blog.list;
    };

    blog = lib.mkPageList {
      data        = data.blog;
      pathPrefix  = "/blog/";
      template    = templates.blog.full;
      layout      = templates.layout;
    };

    feed = {
      path     = "/blog/feed.xml";
      template = templates.feed.atom;
      items    = lib.take 10 blog.list;
      layout   = lib.id;
    };

    err_404 = rec {
      title    = "Error 404";
      section  = "error_404";
      path     = "/404.html";
      template = templates.err_404;
      layout   = templates.layout;
      content  = (lib.loadFile { file = ./content/404.md; }).content;
    };

    about_us = rec {
      title        = "About us";
      section      = "about_us";
      path         = "/about_us/index.html";
      template     = templates.page.sections;
      layout       = templates.layout;
      lede         = sections.lede.content;
      sectionOrder = [ "team" "vision" ];
      sections     = lib.loadDir {
        dir = ./content/about_us;
        env = { inherit (data) team; inherit lib; };
        asAttrs = true;
      };
    };

    faqs = rec {
      title    = "FAQs";
      section  = "faqs";
      path     = "/faqs/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = sections.faqs.content;
      footer   = sections.footer.content;
      sections = lib.loadDir {
        dir = ./content/faqs;
        env = { inherit (data) faqs; inherit lib; };
        asAttrs = true;
      };
    };

    /* ico = rec {
      title    = "ICO";
      section  = "ico";
      path     = "/ico/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = (lib.loadFile { file = ./content/ico/comic.md; }).content;
      footer   = "";
    };

    ico_detail = rec {
      title    = "";
      section  = "ico-details";
      path     = "/ico/details/index.html";
      template = templates.page.full;
      layout   = templates.layout;
      content  = (lib.loadFile { file = ./content/ico/details.md; }).content;
    }; */

  };


/*-----------------------------------------------------------------------------
   Site

-----------------------------------------------------------------------------*/

  /* Converting the pages attribute set to a list
  */
  pageList = lib.pagesToList { inherit pages; };

  /* Generating the site
  */
  site = lib.mkSite {
    inherit files pageList;
    postGen = ''
      echo "${conf.domain}" > $out/CNAME
    '';
  };
}
