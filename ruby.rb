# encoding: utf-8

require 'csv'
require 'digest'
require 'highline/import'
require 'thread'
require 'ruby-progressbar'
require 'choice'


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
    desc 'Set one of severals SSID of the targeted access point'
    valid %w[quick normal long]
    default "normal"
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
      puts "cp-ghost v0.2"
      exit      
    end
  end
end

    ctr = 0
    @client_macs = {}
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
    @ap_macs.each { |ap_mac, target_ssid| break unless ap_mac == row[05][1..-1]; @client_macs[row[0]] = target_ssid} if status == 1 && row[0]
    status = 1 if row[0] == "Station MAC"

  end
  puts "#{@client_macs.count} clients connected."
  puts @client_macs

end

system("sudo ifconfig wlan0 down")
system("sudo iwconfig wlan0 mode monitor")
system("sudo rm ~/.shidopwn/*") if system("mkdir -p ~/.shidopwn")

counter = Thread.new do
  system('cd .shidopwn && sudo airodump-ng -w last wlan0 >/dev/null 2>&1')
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
# rendering a nice table in the end x
# Create a connexion x
# Fix path problems x
# Save the output table x
# Control C escaping
# Nice readme
