require 'mkmf'
$CFLAGS << ' -std=c99 -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers'
if RbConfig::CONFIG['host_os'] !~ /linux/ || Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7")
  $CFLAGS << ' -Werror'
end
compiler = RbConfig::MAKEFILE_CONFIG['CC']
if ENV['DEBUG'] == 'true' && compiler =~ /gcc|g\+\+/
  $CFLAGS << ' -fbounds-check'
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7.0") # added in 2.7
  $CFLAGS << ' -DHAVE_RB_HASH_BULK_INSERT'
end

$warnflags.gsub!(/-Wdeclaration-after-statement/, "") if $warnflags
create_makefile("liquid_c")
