#!/bin/bash

FILE="/data/Project/bash/trainer.lst"
numstr=""
NUMSTRING="$(cat $FILE | wc -l)"
NUMTRY=12
FARR[$NUMSTRING]=""
FARCOUNT="1"


while true
do
	echo ""
	echo "Всего строк: $NUMSTRING"
	echo "Всего попыток: $NUMTRY"
	echo "Осталось попыток: $NUMTRY"
	echo "___________________________"
	echo "Напишите x, что бы выйти"
	echo "Напишите c, что бы отчистить экран"
	echo "Укажите номер строки:"

	read -s numstr
	echo -e "Вы ввели: "$numstr'\n'

	if (echo $numstr | grep "x" > /dev/null)
	then
		echo "Выполнен выход"
		exit 0
	elif (echo $numstr | grep "c" > /dev/null)
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

	# Read file to array
	while read STRINGTXT
	do
		FARR[$FARCOUNT]="$STRINGTXT"
		FARCOUNT="$(($FARCOUNT+1))"
	done < $FILE

	if [ -z ${FARR[$numstr]} ] 2>/dev/null
	then
		echo "Ошибка: строка в файле пустая, попробуйте ещё раз"
		continue
	fi

	echo "Вопрос: "${FARR[$numstr]} | awk -F'*' '{print $1'\n'}'
	echo -e "Введите ответ:\n"
			
	read ansver

	LONGSTRING="$(echo ${FARR[$numstr]} | awk -F "*" '{print $2}' |sed -e "s/[[:space:]]\+//g")"
	ANSVERSTRING="$(echo $ansver | sed -e "s/[[:space:]]\+//g")"

	if [ "$LONGSTRING" == "$ANSVERSTRING" ]
	then
		echo -e "\tПравильно!\n"
		exit 0
	fi

	echo -e "\tВы ошиблись"

	NUMTRY="$(echo $NUMTRY - 1 | bc)"

	if [ $NUMTRY -eq 0 ]
	then
		echo "Все попытки исчерпаны"
		exit 0
	fi

	echo -e "\tПопробуйте ещё раз!\n"

done

