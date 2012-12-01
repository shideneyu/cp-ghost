require 'csv'
require 'digest'
require 'highline/import'
require 'thread'
require 'simple_progressbar'

    ctr = 0
    @client_mac = []
   	scndstatus = 0
    status = 0

def prompt
  @essid = ask('Type network name: ')
end

remaining_part = proc do
  CSV.foreach(".shidopwn/last-01.csv") do |row|
    # Recupere l'adresse mac de l'ap
    #For essid in essids
    if row[13] == " " + @essid
      @ap_mac = row[0] unless (status + scndstatus) == 2
    end

    # Client mac
    if row[00] == "Station MAC" then
      status = 1
    end
    if " #{@ap_mac}" == row[05] && status + scndstatus == 2 then
      @client_mac << row[0]
    end
    scndstatus = 1 if status == 1
  end
  puts "#{@client_mac.count} clients connected."
  puts @client_mac
    #puts "#{ctr} rows"
   	#puts @data[2]
end

#def find(message)
#  puts "The access point is #{message}"
#  @essid = message
#end
prompt
system("sudo ifconfig wlan0 down")
system("sudo iwconfig wlan0 mode monitor")
system("sudo rm ~/.shidopwn/*") if system("mkdir -p ~/.shidopwn")

counter = Thread.new do
  system('cd .shidopwn && sudo airodump-ng -w last wlan0 >/dev/null 2>&1')
end
SimpleProgressbar.new.show("Scanning #{@essid}") do
  (0..10).each do |i|
    progress i*10
    sleep(2)
  end
end

remaining_part.call
system("sudo killall airodump-ng")

# To do list
# Parameting mass ssid assignments
# --ssid option
# --help option
# --connected client verified
# --long scan [opionnal, seconds remaining]
# Choose gem
# rendering a nice table in the end
# Create a connexion
# Fix path problems
# Show computers name in the output table
# Save the output table
# Changing progress bar
