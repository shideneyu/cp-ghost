# encoding: utf-8

require 'csv'
require 'digest'
require 'highline/import'
require 'thread'
require 'simple_progressbar'
require 'choice'



PROGRAM_VERSION = 4

Choice.options do
  header ''
  header 'Specific options:'

  option :ssid, :required => true do
    short '-s'
    long '--ssid *SSID'
    desc 'Set one of severals SSID of the targeted access point'
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
      puts "ftpd.rb FTP server v#{PROGRAM_VERSION}"
      exit      
    end
  end
end




    ctr = 0
    @client_macs = {}
    @ap_macs = {}
   	scndstatus = 0
    status = 0

puts Choice.choices[:ssid]
puts Choice.choices[:ssid].class

remaining_part = proc do
  CSV.foreach(".shidopwn/last-01.csv") do |row|
    ctr += 1
    # Recupere l'adresse mac de l'ap
    #  if row[13] == " " + target_ssid
    #    @ap_mac << row[0] unless status == 1
    #  end
    #end
    Choice.choices[:ssid].each { |target_ssid| puts target_ssid == row[13][1..-1] if row[13]}
    Choice.choices[:ssid].each { |target_ssid| @ap_macs[row[0]] = target_ssid and break if target_ssid == row[13][1..-1]} if row[13] && status == 0

    #if row[13] && status == 0
    #  @essids.each do |target_ssid| 
    #    if target_ssid == row[13][1..-1]
    #      @ap_macs[row[0]] = target_ssid
    #    else
    #      break
    #    end
    #  end
    #end

    #for ap_mac in @ap_mac
    #  if " #{@ap_mac}" == row[05] && status == 1 then
    #    @client_mac << row[0]
    #  end
    #end
    @ap_macs.each { |ap_mac, target_ssid| break unless ap_mac == row[05][1..-1]; @client_macs[row[0]] = target_ssid} if status == 1 && row[0]
    
    status = 1 if row[0] == "Station MAC"
  end
  puts "#{@client_macs.count} clients connected."
    puts @client_macs
    #puts "#{ctr} rows"
   	#puts @data[2]
end

#def find(message)
#  puts "The access point is #{message}"
#  @target_ssid = message
#end
system("sudo ifconfig wlan0 down")
system("sudo iwconfig wlan0 mode monitor")
system("sudo rm ~/.shidopwn/*") if system("mkdir -p ~/.shidopwn")

counter = Thread.new do
  system('cd .shidopwn && sudo airodump-ng -w last wlan0 >/dev/null 2>&1')
end
SimpleProgressbar.new.show("Scanning #{@target_ssid}") do
  (0..10).each do |i|
    progress i*10
    sleep(2)
  end
end

remaining_part.call
system("sudo killall airodump-ng")

# To do list
# Parameting mass ssid assignments V
# --ssid option V
# --help option V
# --connected client verified V
# Choose gem V
# Show computers name in the output table V
# --long scan [opionnal, seconds remaining] x
# rendering a nice table in the end x
# Create a connexion x
# Fix path problems x
# Save the output table x
# Changing progress bar x
