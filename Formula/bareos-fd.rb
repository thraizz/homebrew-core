class BareosFd < Formula
  desc "Open-Source Data Protection Solution"
  homepage "https://bareos.org"
  url "https://github.com/bareos/bareos/archive/bareos-17.2.tar.gz"
  version "17.2.1"
  sha256 "05ccd5b6348627578ed995244a9f0fca3c27a3eb0d217398a762b7f28a5ad948"
  head "https://github.com/bareos/bareos.git"

  depends_on "readline"
  depends_on "openssl"
  depends_on "python"

  def install
    system "./configure", "--prefix=#{prefix}",
    "--prefix=#{prefix}",
    "--with-archivedir=#{prefix}/var/bareos",
    "--with-configtemplatedir=#{lib}/bareos/defaultconfigs",
    "--with-scriptdir=#{lib}/bareos/scripts",
    "--with-plugindir=#{lib}/bareos/plugins",
    "--with-fd-password=XXX_REPLACE_WITH_CLIENT_PASSWORD_XXX",
    "--with-mon-fd-password=XXX_REPLACE_WITH_CLIENT_MONITOR_PASSWORD_XXX",
    "--with-basename=XXX_REPLACE_WITH_LOCAL_HOSTNAME_XXX",
    "--with-hostname=XXX_REPLACE_WITH_LOCAL_HOSTNAME_XXX",
    "--with-python",
    "--enable-client-only"

    system "make"
    rm "platforms/osx/Makefile"
    system "make", "install"
  end

  def post_install
    system "#{lib}/bareos/scripts/bareos-config", "deploy_config", "#{lib}/bareos/defaultconfigs", "#{prefix}/etc/bareos", "bareos-fd"
    system "#{lib}/bareos/scripts/bareos-config", "deploy_config", "#{lib}/bareos/defaultconfigs", "#{prefix}/etc/bareos", "bconsole"
    # Load startup item
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
            <key>Label</key>
            <string>#{plist_name}</string>
            <key>ProgramArguments</key>
            <array>
                    <string>#{sbin}/bareos-fd</string>
                    <string>-f</string>
            </array>

            <key>StandardOutPath</key>
            <string>#{var}/run/bareos-fd.log</string>

            <key>StandardErrorPath</key>
            <string>#{var}/run/bareos.log</string>

            <key>RunAtLoad</key>
            <true/>
    </dict>
    </plist>
  EOS
  end

  test do
    output = shell_output "sudo lsof -n -iTCP:9102 | grep LISTEN"
    assert_match "Bareos is listening under:", output
  end
end
