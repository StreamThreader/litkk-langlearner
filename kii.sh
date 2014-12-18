#!/bin/bash

FILE="/data/Project/bash/trainer.lst"
numstr=""
NUMTRY=12
FARCOUNT="0"


echo ""

if [ -f "$FILE" ]
then
	echo "Файл $FILE обнаружен"
else
	echo "Файл $FILE не обнаружен"
	exit 1
fi

# Read file to array
while read STRINGTXT
do
	# Skip comments "#"
	if [ -n "$STRINGTXT" ] && !(echo $STRINGTXT | grep "^#" > /dev/null 2>&1 )
	then
		FARR[$FARCOUNT]="$(echo "$STRINGTXT" | sed -e "s/[[:space:]]\+/\ /g")"
		FARCOUNT="$(($FARCOUNT+1))"
	fi
done < $FILE

NUMSTRING=${#FARR[@]}

echo "Содержимое файла прочитано в память"

while true
do
	echo "Отсчёт строк начинается от 0"
	echo "Всего строк: $NUMSTRING"
	echo "Всего попыток: $NUMTRY"
	echo "Осталось попыток: $NUMTRY"
	echo "___________________________"
	echo "Напишите x, что бы выйти"
	echo "Укажите номер строки:"

	read -s numstr
	echo -e "Вы ввели: "$numstr'\n'

	if (echo $numstr | grep -x "x" > /dev/null)
	then
		echo "Выполнен выход"
		exit 0
	fi

	if ! [[ $numstr =~ [[:digit:]] ]]
	then
		echo "Ввдёный символ: $numstr, нельзя использовать в качестве номера строки, попробуйте ещё раз"
		continue
	fi

	if [ $numstr -gt $NUMSTRING ]
	then
		echo "Ввдёное число: $numstr, слишком большое"
		echo "Попробуйте ввести любое число меньшее чем $NUMSTRING"
		continue
	fi

	if [ -z ${FARR[$numstr]} ] 2>/dev/null
	then
		echo "Ошибка: строка в файле пустая, попробуйте ещё раз"
		continue
	fi

	if [ "2" != "$(echo ${FARR[$numstr]} | awk -F "*" '{print NF}')" ]
	then
		echo ""
		echo "В выбраной строке обнаружено более одного символа разделителя [ * ]"
		echo "строка $numstr не может быть использована!"
		echo ""
		continue
	fi

	echo -e "Вопрос: $(tput setaf 2)"${FARR[$numstr]} | awk -F'*' '{print $1'\n'}'
	tput sgr 0
	echo -e "Введите ответ:\n"
			
	# Read second part after * and remove spaces
	ORIGSTRING="$(echo ${FARR[$numstr]} | awk -F "*" '{print $2}' |sed -e "s/[[:space:]]\+/*/g")"

	ORIGFIL="$(echo "$ORIGSTRING" | awk -F "," '{print NF}')"

	for i in $(seq 1 $ORIGFIL)
	do
		ORIGARR[$i]="$(echo "$ORIGSTRING" | awk -v i=$i -F ',' '{print $i}')"
	done

	read ansver

	ANSSTRING="$(echo "$ansver" | sed -e "s/[[:space:]]\+/*/g")"

	ANSFIL="$(echo "$ANSSTRING" | awk -F "," '{print NF}')"


	for i in $(seq 1 $ANSFIL)
	do
		ANSARR[$i]="$(echo $ANSSTRING | awk -v i=$i -F ',' '{print $i}')"
	done

	HIT="0"

	# Start comaprsion
	for i in $(seq 1 $ORIGFIL)
	do
		for a in $(seq 1 $ANSFIL)
		do
			ORIGCOMP="$(echo ${ORIGARR[$i]} | sed -e "s/*//g")"
			ANSCOMP="$(echo ${ANSARR[$a]} | sed -e "s/*//g")"

			if [ "$ORIGCOMP" == "$ANSCOMP" ]
			then
				HIT="$(echo $HIT"+1" | bc)"
			fi
		done
	done

	RIGHTANS="$(echo $ORIGSTRING | sed -e "s/*/\ /g")"

	if [ $HIT -eq 0 ]
	then
		tput setaf 1
		echo -e "\tВаш ответ не совпал\n"
		tput sgr 0
	elif [ $ORIGFIL -gt $HIT ]
	then
		echo -e "\tВы набрали $(tput setaf 6)$HIT$(tput sgr 0) очков из $(tput setaf 2)$ORIGFIL$(tput sgr 0) возможных\n"
	else
		tput setaf 3
		echo -e "\tВаш ответ полностью совпадает!\n"
		tput sgr 0
		echo -e "\tс оригиналом: "$RIGHTANS"\n"

	        echo -e "\n\n\nНажмите Enter для продолжения!\n"

	        read

	        clear

		tput sgr 0

		continue
	fi

	echo -e "\tОтвет был таков: $(tput setaf 5)"$RIGHTANS"$(tput sgr 0)\n"

	NUMTRY="$(echo $NUMTRY - 1 | bc)"

	if [ $NUMTRY -eq 0 ]
	then
		echo "Все попытки исчерпаны"
		exit 0
	fi

	echo -e "\n\n\nНажмите Enter для продолжения!\n"

	read

	clear

	tput sgr 0
done

