#!/bin/sh

pacman -Qm > pacmanqm.txt
L=$(cat pacmanqm.txt | wc -l)
touch nu.txt
touch u.txt
COUNTER=1
echo -e "Details on locally installed AUR packages:"
    until [  $COUNTER -gt $L ]; do
              cat pacmanqm.txt | awk 'NR=='${COUNTER}'' > pacmanqm1.txt
              cat pacmanqm1.txt | awk '{print $1}' > pacmanqm11.txt
              N="$(cat pacmanqm11.txt)" 
              echo -e "\e[1mPackage ${COUNTER}\e[0m ($N): "
              cat /var/log/pacman.log | grep -a "${N}" | grep -a '\[ALPM]' | tail -1 > loggy11.txt
              cat loggy11.txt | awk '{print $1,$2}' | sed 's/\(\[\|\]\)//g' > loggy12.txt
              D1=$(sed -n '1p' loggy12.txt)
              t1=`date --date="$D1" +%s`
              echo -e "Checking $N git log info"
              curl -s "https://aur.archlinux.org/cgit/aur.git/log/?h=${N}" > log1.txt
              cat log1.txt | grep -a -m 1 "</span></td><td>*" > days1.txt
              grep -a -o "title=.*</span>" days1.txt | sed -e 's/\<title\>//g' | sed -e 's/\<span\>//g' | sed 's|[<=/>]||g' | sed "s/'//g" > days1s.txt
              cat days1s.txt | awk '{print $1,$2}' > days1s2.txt
              D2=$(sed -n '1p' days1s2.txt)
              t2=`date --date="$D2" +%s`
              let "tDiff1=$t2-$t1"
                      if [  "$tDiff1" -lt 0  ];
                      then 
                      echo -e "up to date"
                      echo $N >> u.txt
                      else
                      echo -e "needs an update!"
                      echo $N, link to download: https://aur.archlinux.org/packages/$N >> nu.txt
                      fi
              rm pacmanqm1.txt
              rm pacmanqm11.txt
              rm days1.txt
              rm days1s2.txt
              rm days1s.txt
              rm log1.txt
              rm loggy11.txt
              rm loggy12.txt
              let COUNTER=COUNTER+1
    done
L2=$(cat u.txt | wc -l)
echo -e "\e[1mUp to date packages:\e[0m $L2 out of $L"
rm u.txt
L3=$(cat nu.txt | wc -l)
echo -e "\e[1mPackages to update:\e[0m $L3 out of $L"
cat nu.txt
rm nu.txt
rm pacmanqm.txt
