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
	echo "Отсчёт строк начинаеться от 0"
	echo "Всего строк: $NUMSTRING"
	echo "Всего попыток: $NUMTRY"
	echo "Осталось попыток: $NUMTRY"
	echo "___________________________"
	echo "Напишите x, что бы выйти"
	echo "Напишите c, что бы отчистить экран"
	echo "Укажите номер строки:"

	read -s numstr
	echo -e "Вы ввели: "$numstr'\n'

	if (echo $numstr | grep -x "x" > /dev/null)
	then
		echo "Выполнен выход"
		exit 0
	elif (echo $numstr | grep -x "c" > /dev/null)
	then
		clear
		continue
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

	echo "Вопрос: "${FARR[$numstr]} | awk -F'*' '{print $1'\n'}'
	echo -e "Введите ответ:\n"
			
	# Read two part after * and remove spaces
	ORIGSTRING="$(echo ${FARR[$numstr]} | awk -F "*" '{print $2}' |sed -e "s/[[:space:]]\+/*/g")"

	ORIGFIL="$(echo "$ORIGSTRING" | awk -F "," '{print NF}')"

	for i in $(seq $ORIGFIL)
	do
		ORIGARR[$i]="$(echo "$ORIGSTRING" | awk -F "," '{print $i}')"
	done


	read ansver

	ANSSTRING="$(echo "$ansver" | sed -e "s/[[:space:]]\+/*/g")"

	ANSFIL="$(echo "$ANSSTRING" | awk -F "," '{print NF}')"


	for i in $(seq $ORIGFIL)
	do
		ANSARR[$i]="$(echo "$ansver" | awk -F "," '{print $i}')"
	done

	HIT="0"

	for i in $(seq $ORIGFIL)
	do
		for a in $(seq $ORIGFIL)
		do
			VARA="$(echo ${ORIGARR[$i]} | sed -e "s/*//g")"
			VARB="$(echo ${ANSARR[$a]} | sed -e "s/*//g")"

			echo "$VARA---"
			echo "$VARB---"

			if [ "$VARA" == "$VARB" ]
			then
				(($HIT+1))
			fi
		done
	done

	RIGHTANS="$(echo $ORIGSTRING | sed -e "s/*/\ /g")"

	if [ $HIT -eq 0 ]
	then
		echo -e "\tВаш ответ не совпал\n"
	elif [ $ORIGFIL -gt $HIT ]
	then
		echo -e "\tВы набрали $HIT очков из $ORIGFIL возможных\n"
	else
		echo -e "\tВаш ответ полностью совпадает!\n"
		echo -e "\tС оригиналом: "$RIGHTANS"\n"
		continue
	fi

	echo -e "\tОтвет был таков: "$RIGHTANS"\n"

	NUMTRY="$(echo $NUMTRY - 1 | bc)"

	if [ $NUMTRY -eq 0 ]
	then
		echo "Все попытки исчерпаны"
		exit 0
	fi

	echo -e "\tПопробуйте ещё раз!\n"
done

