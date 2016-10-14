logman create counter BASELINE -s <YourHyperVServer> -f bincirc -max 500 -si 2 --v –o "c:\perflogs\SERVERBASELINE" -cf "\\<YourFileServer>\<YourShare>\host_baseline.config"

logman -s <YourHyperVServer> start BASELINE