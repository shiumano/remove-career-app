#!/bin/bash

pkgs=`adb shell pm list package |
      sed -e "s/package://g"`  #メモリが吹き飛ぶほどアプリが入ってるなら訴訟モンだよ

carrier_pkgs=`echo "$pkgs" |
              grep -e 'docomo' \
                   -e 'ntt' \
                   -e 'auone' \
                   -e 'rakuten' \
                   -e 'kddi' \
                   -e 'softbank'` \

echo "$carrier_pkgs"

echo -n "以上のアプリが消去されます [Y/n]: "
read ANS

case $ANS in
  "" | [Yy]* )
    echo "$carrier_pkgs" |\
    while read pkg
    do
      echo $pkg
      adb uninstall --user 0 $pkg
    done
    echo "アプリの消去を実行しました"
    ;;
  * )
    echo "処理を中止しました。"
    ;;
esac
