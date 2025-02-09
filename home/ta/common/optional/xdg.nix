{ pkgs, ... }:
let
  # FIXME(xdg): That should use config options and just reference whatever is configured as the default
  browser = [ "firefox.desktop" ];
  editor = [ "nvim.desktop" ];
  media = [ "vlc.desktop" ];
  writer = [ "libreoffice-writer.desktop" ];
  spreadsheet = [ "libreoffice-calc.desktop" ];
  slidedeck = [ "libreoffice-impress.desktop" ];
  # Extensive list of associations here:
  # https://github.com/iggut/GamiNiX/blob/8070528de419703e13b4d234ef39f05966a7fafb/system/desktop/home-main.nix#L77
  associations = {
    "text/*" = editor;
    "text/plain" = editor;

    # "text/html" = browser;
    "application/x-zerosize" = editor; # empty files

    "application/x-shellscript" = editor;
    "application/x-perl" = editor;
    "application/json" = editor;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;
    "application/pdf" = browser;
    "application/mxf" = media;
    "application/sdp" = media;
    "application/smil" = media;
    "application/streamingmedia" = media;
    "application/vnd.apple.mpegurl" = media;
    "application/vnd.ms-asf" = media;
    "application/vnd.rn-realmedia" = media;
    "application/vnd.rn-realmedia-vbr" = media;
    "application/x-cue" = media;
    "application/x-extension-m4a" = media;
    "application/x-extension-mp4" = media;
    "application/x-matroska" = media;
    "application/x-mpegurl" = media;
    "application/x-ogm" = media;
    "application/x-ogm-video" = media;
    "application/x-shorten" = media;
    "application/x-smil" = media;
    "application/x-streamingmedia" = media;

    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;

    "audio/*" = media;
    "video/*" = media;
    "image/*" = browser;

    "x-scheme-handler/sgnl" = "signal-desktop.desktop";
    "application/x-010intel" = "010editor-import.desktop";
    "application/x-010motorola" = "010editor-import.desktop";
    "application/x-010project" = "010editor-project.desktop";
    "application/x-010script" = "010editor.desktop";
    "application/x-010template" = "010editor.desktop";
    "application/x-010workspace" = "010editor-project.desktop";
    "application/x-synology-drive-doc" = "synology-drive-open-file.desktop";
    "application/x-synology-drive-sheet" = "synology-drive-open-file.desktop";
    "application/x-synology-drive-slides" = "synology-drive-open-file.desktop";

    #
    # Drawio
    #
    "application/vnd.jgraph.mxfile" = [ "drawio.desktop" ];
    "application/vnd.jgraph.mxfile.realtime" = [ "drawio.desktop" ];

    #
    # Office Stuff
    #
    "text/csv" = spreadsheet;
    "application/vnd.ms-excel" = spreadsheet;
    "application/vnd.ms-powerpoint" = slidedeck;
    "application/vnd.ms-word" = writer;
    "application/vnd.oasis.opendocument.database" = [ "libreoffice-base.desktop" ];
    "application/vnd.oasis.opendocument.formula" = [ "libreoffice-math.desktop" ];
    "application/vnd.oasis.opendocument.graphics" = [ "libreoffice-draw.desktop" ];
    "application/vnd.oasis.opendocument.graphics-template" = [ "libreoffice-draw.desktop" ];
    "application/vnd.oasis.opendocument.presentation" = slidedeck;
    "application/vnd.oasis.opendocument.presentation-template" = slidedeck;
    "application/vnd.oasis.opendocument.spreadsheet" = spreadsheet;
    "application/vnd.oasis.opendocument.spreadsheet-template" = spreadsheet;
    "application/vnd.oasis.opendocument.text" = writer;
    "application/vnd.oasis.opendocument.text-master" = writer;
    "application/vnd.oasis.opendocument.text-template" = writer;
    "application/vnd.oasis.opendocument.text-web" = writer;
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = slidedeck;
    "application/vnd.openxmlformats-officedocument.presentationml.template" = slidedeck;
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = spreadsheet;
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = spreadsheet;
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = writer;
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = writer;
    "application/vnd.stardivision.calc" = spreadsheet;
    "application/vnd.stardivision.draw" = [ "libreoffice-draw.desktop" ];
    "application/vnd.stardivision.impress" = slidedeck;
    "application/vnd.stardivision.math" = [ "libreoffice-math.desktop" ];
    "application/vnd.stardivision.writer" = writer;
    "application/vnd.sun.xml.base" = [ "libreoffice-base.desktop" ];
    "application/vnd.sun.xml.calc" = spreadsheet;
    "application/vnd.sun.xml.calc.template" = spreadsheet;
    "application/vnd.sun.xml.draw" = [ "libreoffice-draw.desktop" ];
    "application/vnd.sun.xml.draw.template" = [ "libreoffice-draw.desktop" ];
    "application/vnd.sun.xml.impress" = slidedeck;
    "application/vnd.sun.xml.impress.template" = slidedeck;
    "application/vnd.sun.xml.math" = [ "libreoffice-math.desktop" ];
    "application/vnd.sun.xml.writer" = writer;
    "application/vnd.sun.xml.writer.global" = writer;
    "application/vnd.sun.xml.writer.template" = writer;
    "application/vnd.wordperfect" = writer;

  };
  removals = {
    # Calibre steals odt association from libreoffic so need to remove
    "application/vnd.oasis.opendocument.text" = [
      "calibre-ebook-viewer.desktop"
      "calibre-ebook-edit.desktop"
      "calibre-gui.desktop"
    ];
  };
in
{
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = associations;
  xdg.mimeApps.associations.removed = removals;
  xdg.mimeApps.associations.added = associations;

  home.packages = builtins.attrValues {
    inherit (pkgs)
      handlr-regex # better xdg-open for desktop apps
      ;
  };
}
