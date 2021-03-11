function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }

$1 == "BSS" {
    MAC = $2
    wifi[MAC]["enc"] = "-"
}
$1 == "SSID:" {
    wifi[MAC]["SSID"] = rtrim( $2" "$3" "$4" "$5" "$6)
}
$1 == "freq:" {
    wifi[MAC]["freq"] = $NF
}
$1 == "signal:" {
    #wifi[MAC]["sig"] = int ( (100 - $2) / 10) #" " $3
    wifi[MAC]["sig"] = int( (-0.0154*$2*$2)-(0.3794*$2)+98.182)
    if( $2 > -21) { wifi[MAC]["sig"] = 100 }
    if( $2 < -92) { wifi[MAC]["sig"] = 1}
    
}
$1 == "RSN:" {
    wifi[MAC]["enc"] = "WPA"
}
END {
    #printf "%s\t%s\t%s\n","SSID","Signal","Encryption"

    for (w in wifi) {
    	#printf "[%s]\n",wifi[w]["SSID"]
        #printf "%s\t%s\t%s\n",wifi[w]["SSID"],wifi[w]["sig"],wifi[w]["enc"]
        if( wifi[w]["SSID"] != "") {
            #printf "'%s' '%s% (%s)' 'OFF' ",wifi[w]["SSID"],wifi[w]["sig"],wifi[w]["enc"]
            printf "'%s' '      %s%     (%s)' ",wifi[w]["SSID"],wifi[w]["sig"],wifi[w]["enc"]
        }
    }
    printf "'%s' '      %s' ","Connect to a Hidden Network","-"
    
}
