#!/bin/bash

#
# Author:	Oleg A. Deordiev
# For:		LITKK
# Developed:	2015
#
# Programm for learn some text with check itself
#
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
NUMSTRING=				# Number of string
USERNUMSTR=				# User choise number of string
userchoise=				# User choise for program question
EERQ[0]=0				# Array failed questions (pointer)
ERRCOUNTER=				# Counter of recheck question
ALLERR=0				# Miss counter
MISNUM=3				# How many iteration can by before insert
					# not ansvered question


###########################################################################


if [ -f "$FILE" ]
then
	echo -e "\nФайл $FILE обнаружен"
else
	echo -e "\nФайл $FILE не обнаружен\n"
	exit 1
fi

COUNTER=0

# Function check user ansver Yes or No
yesnofun() {
	TEXTMSG="$1"
	USERANSVER=

	while true
	do
		echo $TEXTMSG" [Yes/No]"

		read -s USERANSVER

		if [[ $USERANSVER =~ ^([yY][eE][sS]|[yY])$ ]]
		then
			USERANSVER=0
			break
		elif [[ $USERANSVER =~ ^([nN][oO]|[nN])$ ]]
		then
			USERANSVER=1
			break
		else
			echo -e $USERANSVER" - не правильный выбор, используйте Yes или No\n"
			continue
		fi
	done

	return $USERANSVER
}

# Request user to input numbers
numinfun() {
	TEXTMSG="$1"
	USERANSVER=

	while true
	do
		echo $TEXTMSG

		read USERANSVER

		if [[ $USERANSVER =~ ^[[:digit:]]{1,}$ ]]
		then
			break
		else
			echo -e "Ввдёное число: $USERANSVER, нельзя использовать, попробуйте ещё раз\n"
			continue
		fi
	done

	retval=$USERANSVER

	return 0
}



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


# Request user range
if yesnofun "Использовать случайный порядок?"
then
	if yesnofun "Указать диапозон вручную?"
	then
		while true
		do
			numinfun "Укажите нижний порог"
			lowbord="$retval"

			if [[ $lowbord -gt $NUMSTRING ]]
			then
				echo -e "Нижний порог не может быть больше числа $NUMSTRING\n"
				continue
			else
				break
			fi
		done

		while true
		do

			numinfun "Укажите верхний порог"
			highbord="$retval"

			if [[ $highbord -gt $NUMSTRING ]]
			then
				echo -e "Верхний порог не может быть больше числа $NUMSTRING\n"
				continue
			else
				break
			fi
		done

		# From there NUMSTRING - is number of strig (not a upper limit)
		NUMSTRING=$(($highbord-$lowbord))
	else
		echo -e "Будет использован диапозон: 0 - $NUMSTRING\n"

		lowbord=0
		highbord=$NUMSTRING
	fi

	# Randomize sequence to array
	COUNTER=0
	for i in $(seq $lowbord $highbord | sort -R)
	do
		RANDSEQ[$COUNTER]=$i
		COUNTER=$(($COUNTER+1))

	done

	USERAND="YES"
else
	USERAND="NO"
	lowbord=0
	highbord=$NUMSTRING
fi

userchoise=
COUNTER=0
#clear


while true
do
	echo "Отсчёт строк начинается от $lowbord"
	echo "Всего строк: $NUMSTRING"
	echo "Всего попыток: $NUMTRY"
	echo "Осталось попыток: $NUMTRY"
	echo "Правильных ответов:"
	echo "Допущено ошибок:"
	echo "Исправлено ошибок:"
	echo "___________________________"

	if [[ $MISNUM -gt $ERRCOUNTER ]]
	then
		if [ $USERAND == NO ]
		then
			numinfun "Укажите номер строки:"
			USERNUMSTR="$retval"
			
			echo -e "Вы ввели: $USERNUMSTR\n"

			if [[ $USERNUMSTR -gt $highbord ]]
			then
				echo "Ввдёное число: $USERNUMSTR, слишком большое"
				echo "Попробуйте ввести любое число меньшее чем $highbord"
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
	elif [[ $MISNUM -eq $ERRCOUNTER ]]
	then
		# Insert question from not ansvered array
		for i in seq 0 ${#EERQ[*]}
		do
			# If array item not pointer
			if [[ ${ERRQ[$i]} == "OK" ]]
			then
				continue
			else
				USERNUMSTR=${ERRQ[$i]}
				echo -e "Произведена вставка вопроса на который был дан не верный ответ"
				echo "-"$USERNUMSTR"--"${#EERQ[*]}
			fi
		done
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
				HIT=$(($HIT+1))
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
		echo -e "\tВы набрали $(tput setaf 6)$HIT$(tput sgr 0) очков из\
		       	$(tput setaf 2)$ORIGFIL$(tput sgr 0) возможных\n"
	else
		tput setaf 3
		echo -e "\tВаш ответ полностью совпадает!\n"
		tput sgr 0
		echo -e "\tс оригиналом: "$RIGHTANS"\n"

	        echo -e "\n\n\nНажмите Enter для продолжения!\n"

	        read

#	        clear

		tput sgr 0

		continue
	fi

	echo -e "\tОтвет был таков: $(tput setaf 5)"$RIGHTANS"$(tput sgr 0)\n"

	# If this recheck MISS question, disable counter
	if [[ $MISNUM -gt $ERRCOUNTER ]]
	then
		NUMTRY=$(($NUMTRY-1))
	
		if [ $NUMTRY -eq 0 ]
		then
			echo "Все попытки исчерпаны"
			exit 0
		fi

		ERRCOUNTER=$(($ERRCOUNTER+1))

		# Point to not ansvered question
		EERQ[$ALLERR]=$USERNUMSTR

		# After add pointer, shift to next item
		ALLERR=$(($ALLERR+1))

	elif [[ $MISNUM -eq $ERRCOUNTER ]]
	then
		# If this question is not ansvered, reset counter
		# and after 3 normal question, call not ansvered question
		# controlled with this counter
		ERRCOUNTER=0
	fi

	echo -e "\n\n\nНажмите Enter для продолжения!\n"

	read

#	clear

	tput sgr 0
done

