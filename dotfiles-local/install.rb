#!/usr/bin/ruby

# colourful text output
class String
  def green
    "\e[32m#{self}\e[0m"
  end

  def red
    "\e[31m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end

  def yellow
    "\e[33m#{self}\e[0m"
  end
end

# format title output
def title(string)
  empty_line = ''
  divider = ('=' * string.size).blue
  puts empty_line
  puts divider
  puts string.upcase.blue
  puts divider
end

# format info output
def info(string)
  puts "=> #{string}".green
end

# format warning output
def warn(string)
  puts "/!\\ #{string}".red
end

def print_command(string)
  puts "% #{string}".yellow
end

def run(command)
  print_command command
  if pretend?
    puts '# ♫ just pretend ♫'.blue
  else
    system command
  end
  puts ''
end

def pretend?
  ARGV.include?('--pretend') || ARGV.include?('-p')
end

def verbose?
  ARGV.include?('--verbose') || ARGV.include?('-v')
end

def dependencies?
  (`which ruby` != '') && (`which git` != '')
end

def check_for_dependencies
  return false if dependencies?
  warn 'Install missing dependencies and try again.'
  info 'Ruby and Git are required to run this installer.'
  abort
end

check_for_dependencies

title 'macOS configuration'
info 'Disable diacritics panel on key press and hold'
run 'defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false'

info 'Faster KeyRepeat'
run 'defaults write -g NSGlobalDomain KeyRepeat -int 2'

info 'Faster InitialKeyRepeat'
run 'defaults write -g NSGlobalDomain InitialKeyRepeat -float 15'

info 'Reduce Transparency'
run 'defaults write com.apple.universalaccess reduceTransparency -bool true'

info 'Show Attachments as Icons'
run 'defaults write com.apple.mail DisableInlineAttachmentViewing -bool yes'

info 'Show All File Extensions'
run 'defaults write -g AppleShowAllExtensions -bool true'

info 'Disable Auto-Correct'
run 'defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false'

title 'Screen shot keyboard shortcuts'
key = {
  command: '\@',
  control: '\^',
  option: '\~',
  shift: '\$'
}

shortcuts = [
  {
    title: 'Save picture of screen as a file',
    keys: "#{key[:control]}#{key[:shift]}#{key[:command]}3"
  }, {
    title: 'Copy picture of screen to the clipboard',
    keys: "#{key[:shift]}#{key[:command]}3"
  }, {
    title: 'Save picture of selected area as a file',
    keys: "#{key[:control]}#{key[:shift]}#{key[:command]}4"
  }, {
    title: 'Copy picture of selected area to the clipboard',
    keys: "#{key[:shift]}#{key[:command]}4"
  }
]

shortcuts.each do |shortcut|
  title = shortcut[:title].inspect
  keys = shortcut[:keys].inspect
  formatted_shortcut = "{ #{title} = #{keys} ; }"
  info title
  run "defaults write -g NSUserKeyEquivalents '#{formatted_shortcut}'"
end

# https://github.com/mathiasbynens/dotfiles/blob/master/.macos
title 'SSD specific tweaks'
info 'Disable hibernation (speeds up entering sleep mode)'
run 'sudo pmset -a hibernatemode 0'

info 'Remove the sleep image file to save disk space'
run 'sudo rm /private/var/vm/sleepimage'

info 'Create a zero-byte file instead…'
run 'sudo touch /private/var/vm/sleepimage'

info '…and make sure it can’t be rewritten'
run 'sudo chflags uchg /private/var/vm/sleepimage'

info 'Disable the sudden motion sensor as it’s not useful for SSDs'
run 'sudo pmset -a sms 0'

info 'Finder: disable window animations and Get Info animations'
run 'defaults write com.apple.finder DisableAllAnimations -bool true'

info 'Finder: show hidden files by default'
run 'defaults write com.apple.finder AppleShowAllFiles -bool true'

info 'Finder: show all filename extensions'
run 'defaults write NSGlobalDomain AppleShowAllExtensions -bool true'

info 'Finder: When performing a search, search the current folder by default'
run 'defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"'

info 'Automatically hide and show the Dock'
run 'defaults write com.apple.dock autohide -bool true'

info 'Show the ~/Library folder'
run 'chflags nohidden ~/Library'

info 'Show the /Volumes folder'
run 'sudo chflags nohidden /Volumes'

title 'Privacy & security'
info 'Privacy: don’t send search queries to Apple'
run 'defaults write com.apple.Safari UniversalSearchEnabled -bool false'
run 'defaults write com.apple.Safari SuppressSearchSuggestions -bool true'

info 'Show the full URL in the address bar (note: this still hides the scheme)'
run 'defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true'

info 'Set Safari’s home page to `about:blank` for faster loading'
run 'defaults write com.apple.Safari HomePage -string "about:blank"'

info 'Disable Safari’s thumbnail cache for History and Top Sites'
run 'defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2'

info 'Enable the Develop menu and the Web Inspector in Safari'
run 'defaults write com.apple.Safari IncludeDevelopMenu -bool true'
run 'defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true'
run 'defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true'

info 'Enable "Do Not Track"'
run 'defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true'

info 'Prevent Photos from opening automatically when devices are plugged in'
run 'defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true'

info 'Enable Firewall (will ask password)'
run 'sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on'

info 'Disable AirDrop'
run 'defaults write com.apple.NetworkBrowser DisableAirDrop -bool YES'

title 'Safari Dev'
info 'Enable Develop Menu and Web Inspector'
run 'defaults write com.apple.Safari IncludeInternalDebugMenu -bool true'
run 'defaults write com.apple.Safari IncludeDevelopMenu -bool true'
run 'defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true'
run 'defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true'
run 'defaults write -g WebKitDeveloperExtras -bool true'

