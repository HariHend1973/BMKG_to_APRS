clear
#by YD1RUH
#modified by YD0BCX

#informasi serrver
serverHost="t2kk.kutukupret.com"
serverPort="14580"
callsign="YD0BCX-1"
password="22972"
address="[0] ${callsign}>APRS,WIDE1-1,WIDE2-1:"
login="user $callsign pass $password vers ShellBeacon 1.0"
delay="60" #dalam detik

while true
do

#grabbing data
curl https://data.bmkg.go.id/DataMKG/TEWS/autogempa.xml > autogempa.xml
data=$(cat autogempa.xml); tanggal=$(grep -oPm1 "(?<=<Tanggal>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); jam=$(grep -oPm1 "(?<=<Jam>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); Magnitude=$(grep -oPm1 "(?<=<Magnitude>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); Kedalaman=$(grep -oPm1 "(?<=<Kedalaman>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); Potensi=$(grep -oPm1 "(?<=<Potensi>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); Wilayah=$(grep -oPm1 "(?<=<Wilayah>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); koordinat=$(grep -oPm1 "(?<=<coordinates>)[^<]+" <<< "$data")
koordinat2=$(<<< $koordinat sed 's/,/ /g')
koordinat3=$(GeoConvert -d -p -1 --input-string "$koordinat2")
koordinat4=$(<<< $koordinat3 sed 's/d//g');
koordinat5=$(<<< $koordinat4 sed "s/'/./g");
koordinat6=$(<<< $koordinat5 sed "s/\"//g");
x=$(awk 'NR == 1 {print $1}'  <<< "$koordinat6");
y=$(awk '{print $2}' <<< "$koordinat6");

#construction packet
position="!$x\\$y!"
comment=" $tanggal $jam Magnitude:$Magnitude Kedalaman:$Kedalaman Potensi:$Potensi"
Status="${address}>$Wilayah"
packet="${address}${position}${comment}"

#send data to IG server
cat > tmp/frame << END
$packet
$Status
END
#in another console type
#kissutil -f tmp/

if [ "$1" = "1" ]
then
    exit
fi

sleep $delay
done