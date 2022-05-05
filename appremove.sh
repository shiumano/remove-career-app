#!/bin/bash

gb=$'\e[42m\e[30m'
reset=$'\e[0m'
up=$'\e[1F'
clear=$'\e[K'

repeat() {
  yes $1 |
  head -n $2 |
  tr --d $'\n'
}

progressbar() {
  count=0
  total=$1

  cat |
  while read line
  do
    count=$((count+1))
    percent_int=$(((count*100)/total))
    columns=`tput cols`
    columns=$((columns-7))
    bar_body_length=$((columns*percent_int/100))

    if [ $percent_int != 0 ]
    then
      bar_body=`repeat "#" $bar_body_length`
    fi
    bar_space=`repeat "." $((columns-bar_body_length))`
    percent="  $percent_int"
    bar="$gb"
    bar+="${percent: -3:3}"
    bar+="%"
    bar+="$reset"
    bar+=" ["
    bar+="$bar_body"
    bar+="$bar_space"
    bar+="]"

    echo "$line"
    echo "$clear"
    echo -n "$bar"
    echo -n "$up"
  done
  echo
  echo $clear$up
}


if type "adb" > /dev/null 2>&1; then
  adb shell echo > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    pkgs=`adb shell pm list package |
          sed -e "s/package://g"`
    carrier_pkgs=`echo "$pkgs" |
                  grep -e 'docomo' \
                       -e 'ntt' \
                       -e 'auone' \
                       -e 'rakuten' \
                       -e 'kddi' \
                       -e 'softbank'`
    echo "$carrier_pkgs"
    echo -n "以上のアプリが消去されます [Y/n]: "
    read ANS
    case $ANS in
      "" | [Yy]* )
        echo "$carrier_pkgs" |\
        while read pkg
        do
          echo "$pkg を削除中"
          adb shell pm uninstall --user 0 $pkg
        done |
        progressbar $((`wc -l "$carrier_pkgs"`*2))
        echo "アプリの消去を実行しました"
        ;;
      * )
        echo "処理を中止しました。"
        ;;
    esac
  elif [ $? -eq 1 ]; then
    echo "USBデバッグが有効なデバイスが見つかりません。"
    echo "Android端末が正しく接続されているか確認してください"
  fi
else
  echo "adbコマンドが存在しません。"
  echo "コマンドを自動でインストールします"
  sudo apt install adb -y
  bash $0
fi
