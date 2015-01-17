#!/bin/bash

#
# Author:	Oleg A. Deordiev
# For:		LITKK
# Developed:	2015
#

###########################################################################

FILE="/data/Project/bash/trainer.lst"	# File with question & ansver
NUMTRY=12				# Max number of user errors
COUNTER=				# Counter
FARR[0]=0				# Array of question & ansver
USERAND="NO"				# Use random sequesnce?
lowbord=				# Low border
highbord=				# High borader
RANDSEQ=				# Randomized sequence of strings
STRINGTXT=				# File string to variable
NUMSTRING=				# Number of usable string in file
USERNUMSTR=				# User choise number of string
userchoise=				# User choise for program question


###########################################################################


if [ -f "$FILE" ]
then
	echo "Файл $FILE обнаружен"
else
	echo -e "\nФайл $FILE не обнаружен\n"
	exit 1
fi

COUNTER=0

# Read file to array
while read STRINGTXT
do
	# Skip comments "#"
	if [ -n "$STRINGTXT" ] && !(echo $STRINGTXT | grep "^#" > /dev/null 2>&1 )
	then
		FARR[$COUNTER]="$(echo "$STRINGTXT" | sed -e "s/[[:space:]]\+/\ /g")"
		COUNTER="$(($COUNTER+1))"
	fi
done < $FILE

NUMSTRING=${#FARR[@]}

echo -e "Содержимое файла прочитано в память\n"

echo -e "Использовать случайный порядок? [Y/N]\n"


# Range settings
while true
do
	read userchoise

	if [[ $userchoise =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		USERAND="YES"
		while true
		do
			echo "Указать диапозон вручную? [Y/N]"

			read userchoise

			if [[ $userchoise =~ ^([yY][eE][sS]|[yY])$ ]]
			then
				while true
				do
					echo "Укажите нижний порог"
					read lowbord

					if [ $lowbord -gt $NUMSTRING ]
					then
						echo -e "Нижний порог не может быть больше числа $NUMSTRING\n"
						continue
					fi

					break
				done

				while true
				do
					echo "Укажите верхний порог"
					read highbord

					if [ $highbord -gt $NUMSTRING ]
					then
						echo -e "Верхний порог не может быть больше числа $NUMSTRING\n"
						continue
					fi

					break
				done

				# Limit upper border
				NUMSTRING=$highbord

			elif [[ $userchoise =~ ^([nN][oO]|[nN])$ ]]
			then
				echo -e "Будет использован диапозон: 0 - $NUMSTRING\n"
				lowbord=0
				highbord=$NUMSTRING
			else
				echo "Укажите Y или N"
				continue
			fi

			# Randomize sequence to array
			COUNTER=0
			for i in $(seq $lowbord $highbord | sort -R)
			do
				RANDSEQ[$COUNTER]=$i
				COUNTER=$(($COUNTER+1))
			done

			lowbord=
			highbord=

			break
		done

		break

	elif [[ $userchoise =~ ^([nN][oO]|[nN])$ ]]
	then
		USERAND="NO"
		break
	else
		echo "Укажите Y или N"
		continue
	fi
done

userchoise=
COUNTER=0

while true
do
	echo "Отсчёт строк начинается от 0"
	echo "Всего строк: $NUMSTRING"
	echo "Всего попыток: $NUMTRY"
	echo "Осталось попыток: $NUMTRY"
	echo "___________________________"

	if [ $USERAND == NO ]
	then
		echo "Напишите x, что бы выйти"
		echo "Укажите номер строки:"
		read -s USERNUMSTR
		echo -e "Вы ввели: $USERNUMSTR\n"

		if (echo $USERNUMSTR | grep -x "x" > /dev/null)
		then
			echo "Выполнен выход"
			exit 0
		fi

		if ! [[ $USERNUMSTR =~ [[:digit:]] ]]
		then
			echo "Ввдёный символ: $USERNUMSTR, нельзя использовать в качестве номера строки, попробуйте ещё раз"
			continue
		fi
	
		if [ $USERNUMSTR -gt $NUMSTRING ]
		then
			echo "Ввдёное число: $USERNUMSTR, слишком большое"
			echo "Попробуйте ввести любое число меньшее чем $NUMSTRING"
			continue
		fi

	elif [ $USERAND == YES ]
	then
		if [ $COUNTER == $NUMSTRING ]
		then
			echo -e "\nВы ответили на все вопросы из выбраного диапозона\n"
			exit 0
		fi

		USERNUMSTR=${RANDSEQ[$COUNTER]}
		COUNTER=$(($COUNTER+1))
		echo "В качестве номера строки выбрано: $USERNUMSTR"
	fi

	if [ -z ${FARR[$USERNUMSTR]} ] 2>/dev/null
	then
		echo "Ошибка: строка в файле пустая, попробуйте ещё раз"
		continue
	fi

	if [ "2" != "$(echo ${FARR[$USERNUMSTR]} | awk -F "*" '{print NF}')" ]
	then
		echo ""
		echo "В выбраной строке обнаружено более одного символа разделителя [ * ]"
		echo "строка $USERNUMSTR не может быть использована!"
		echo ""
		continue
	fi

	echo -e "Вопрос: $(tput setaf 2)"${FARR[$USERNUMSTR]} | awk -F'*' '{print $1'\n'}'
	tput sgr 0
	echo -e "Введите ответ:\n"
			
	# Read second part after * and remove spaces
	ORIGSTRING="$(echo ${FARR[$USERNUMSTR]} | awk -F "*" '{print $2}' |sed -e "s/[[:space:]]\+/*/g")"

	ORIGFIL="$(echo "$ORIGSTRING" | awk -F "," '{print NF}')"

	for i in $(seq 1 $ORIGFIL)
	do
		ORIGARR[$i]="$(echo "$ORIGSTRING" | awk -v i=$i -F ',' '{print $i}')"
	done


	# Get user ansver
	read userchoise

	ANSSTRING="$(echo "$userchoise" | sed -e "s/[[:space:]]\+/*/g")"

	userchoise=


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

