clear
#by YD1RUH
#modified by YD0BCX

#informasi serrver
callsign="YD0BCX-1"
address="[0] ${callsign}>APRS,WIDE1-1,WIDE2-1:"
delay="60" #dalam detik

while true
do

#grabbing data
curl -s https://data.bmkg.go.id/DataMKG/TEWS/autogempa.xml > autogempa.xml
data=$(cat autogempa.xml); tanggal=$(grep -oPm1 "(?<=<Tanggal>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); jam=$(grep -oPm1 "(?<=<Jam>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); Magnitude=$(grep -oPm1 "(?<=<Magnitude>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); Kedalaman=$(grep -oPm1 "(?<=<Kedalaman>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); Potensi=$(grep -oPm1 "(?<=<Potensi>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); Wilayah=$(grep -oPm1 "(?<=<Wilayah>)[^<]+" <<< "$data")
data=$(cat autogempa.xml); koordinat=$(grep -oPm1 "(?<=<coordinates>)[^<]+" <<< "$data")
koordinat2=$(<<< $koordinat sed 's/,/ /g')
x=$(echo $koordinat2 | awk '{print $1}')
y=$(echo $koordinat2 | awk '{print $2}')

#construction packet
position=$(aprs-weather-submit -C -k ${callsign} -n ${x}  -e ${y} | sed 's/_.*/!/g' | sed 's/\//\\/g' | sed 's/.*\@/@/')
comment=" $tanggal $jam Magnitude:$Magnitude Kedalaman:$Kedalaman Potensi:$Potensi"
Status="${address}>$Wilayah"
packet="${address}${position}${comment}"

#send data to tmp/frame for kissutill
cat > tmp/frame << END
$packet
$Status
END

echo $packet
echo $Status

if [ "$1" = "1" ]
then
    exit
fi

sleep $delay
done
