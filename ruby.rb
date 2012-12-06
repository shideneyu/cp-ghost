# encoding: utf-8

require 'csv'
require 'digest'
require 'highline/import'
require 'thread'
require 'ruby-progressbar'
require 'choice'
require 'formatador'

Choice.options do
  header ''
  header 'Specific options:'

  option :ssid, :required => true do
    short '-s'
    long '--ssid *SSID'
    desc 'Set one of severals SSID of the targeted access point'
  end

  option :length do
    short '-l'
    long '--length=[length]'
    desc 'Set one of severals SSID of the targeted access point (default: normal)'
    valid %w[quick normal long]
    default "normal"
  end

  option :interface do
    short '-i'
    long '--interface=[interface]'
    desc 'Set the interface of the targeted access point which will be used (default: wlan0)'
    default "wlan0"
  end

  separator ''
  separator 'Common options: '

  option :help do
    long '--help'
    desc 'Show this message'
  end

  option :version do
    short '-v'
    long '--version'
    desc 'Show version'
    action do
      puts "cp-ghost v0.5"
      exit      
    end
  end
end

    ctr = 0
    
    @clients_array = []
    @ap_macs = {}
   	scndstatus = 0
    status = 0

    case Choice.choices[:length]
      when "quick"
        @length = 0.07
      when "normal"
        @length = 0.15
      when "long"
        @length = 0.3
    end

remaining_part = proc do
  CSV.foreach(".shidopwn/last-01.csv") do |row|
    Choice.choices[:ssid].each { |target_ssid| @ap_macs[row[0]] = target_ssid and break if target_ssid == row[13][1..-1]} if row[13] && status == 0
    @ap_macs.each { |ap_mac, target_ssid| @clients_array << Hash.new and @clients_array.last.replace({target_ssid => row[00]})  and break if row[05][1..-1] == ap_mac}  if status == 1 && row[0]
    status = 1 if row[0] == "Station MAC"
  end
  Formatador.display_compact_table(@clients_array) unless @clients_array.empty?
  puts "No results" if @clients_array.empty?

end

system("sudo ifconfig #{Choice.choices[:interface]} down")
system("sudo iwconfig #{Choice.choices[:interface]}  mode monitor")
system("sudo rm ~/.shidopwn/*") if system("mkdir -p ~/.shidopwn")

counter = Thread.new do
  system("cd .shidopwn && sudo airodump-ng -w last #{Choice.choices[:interface]} >/dev/null 2>&1")
end

prog_b = ProgressBar.create(:format => '%a %B %p%% %t')

100.times { sleep(@length) ; prog_b.increment }


remaining_part.call
system("sudo killall airodump-ng")

# To do list
# Parameting mass ssid assignments V
# --ssid option V
# --help option V
# --connected client verified V
# Choose gem V
# Show computers name in the output table V
# Changing progress bar V
# --long scan [opionnal, seconds remaining] V
# rendering a nice table in the end V
# Option to choose network card V
# Create a connexion x
# Fix path problems x
# Save the output table x
# Control C escaping
# Option to listen to all available APs.
# Nice readme