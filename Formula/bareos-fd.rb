class BareosFd < Formula
  desc "Open-Source Data Protection Solution"
  homepage "https://bareos.org"
  url "https://github.com/bareos/bareos/archive/Release/17.2.4.tar.gz"
  sha256 "4c443539012cf5ebb0fdb18878e604e82b951e6429c618acd18762f3c5724799"

  depends_on "readline"
  depends_on "openssl"

  def install
    system "./configure",
    "--prefix=#{prefix}",
    "--sbindir=#{bin}",
    "--with-working-dir=#{var}/lib/bareos",
    "--with-archivedir=#{var}/bareos",
    "--with-confdir=#{etc}/bareos",
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
    # * Makefile is intended to create a .pkg file.
    #   As it is not required or used it's removed.
    rm "platforms/osx/Makefile"
    system "make", "install"
  end

  def post_install
    # The default configuration files are deployed and can be tested in the test-do block.
    return if File.exist?(etc/"bareos/bareos-fd")
    cp_r Dir[lib/"bareos/defaultconfigs/*"], etc/"bareos", :preserve => true
  end

  plist_options :startup => true

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/bareos-fd</string>
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
    # Checks version and tests configuration
    assert_match version.to_s, shell_output("#{bin}/bareos-fd -? 2>&1", 1)
    system "#{bin}/bareos-fd", "-t"
  end
end
