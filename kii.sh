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

FILE="./trainer.lst"			# File with question & ansver
MAXERR=12				# Recomendation of max errors
NUMTRY=$MAXERR				# Left recomended count of error
COUNTER=0				# Counter for some control
FARR[0]=0				# Array of question & ansver
USERAND=				# Use random sequesnce?
lowbord=				# Low border
highbord=				# High borader
RANDSEQ=				# Randomized sequence of strings
STRINGTXT=				# File string to variable
NUMSTRING=				# Number of string
USERNUMSTR=				# User choise number of string
userchoise=				# User choise for program question
ERRQ[0]=0				# Array failed questions (pointer)
SOLVEDERR=0				# How many erros, re-ansvered
INSERTCOUNT=0				# Count turn, for control insert question
ERRCOUNTER=0				# Counter of recheck question
GOODQUEST=0				# Count of good ansvered questions
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

if [ ! -f $FILE ]
then
	echo $FILE" не обнаружен"
	exit
fi

# Read file to array
readarray -t TMPFARR < $FILE

echo -e "Содержимое файла прочитано в память\n"

# Get number of plain strings
RAWSTRNUM=${#TMPFARR[@]}
COUNTER=

echo "Начата обработка строк"

for i in $(seq 0 $RAWSTRNUM)
do
	echo -ne "."
	# Replace continuous multiple spaces by one
	TMPFARR[$i]="$(echo "${TMPFARR[$i]}" | sed -e "s/[[:space:]]\+/\ /g")"

	# Skip empty string from file
	if [ $i -ne $RAWSTRNUM ]
	then
		if [ -z "${TMPFARR[$i]}" ]
		then
			echo -e "Cтрока "$i" в файле пустая, она не будет использоваться"'\n'
			continue
		fi
	else
		echo ">"
		echo "Анализ массива строк завершен на строке: "$i
		echo "после обработки осталось строк: "$COUNTER
		continue
	fi

	# Skip comments from file
	if $(echo ${TMPFARR[$i]} | grep "^#" > /dev/null 2>&1)
	then
		continue
	fi

	# If symbol * occur often then 1 times
	# count number of fields
	NFIEL="$(echo "${TMPFARR[$i]}" | awk -F '*' '{print NF}')"
	if [ 2 -ne $NFIEL ]
	then
		echo "В строке "$i" обнаружено не правильное количество полей разделенных символом [ * ]"
		echo "Такое решение принято, так как в строке найдено "$NFIEL" пол(я/е/ей), а должно быть 2"
		echo "Из-за этой ошибки, строка не будет использоваться"
		echo -e "Проанализируйте ошибочную строку: ["$TMPFARR[$i]"]"'\n'
		NFIEL=
		continue
	fi

	FARR[$COUNTER]=${TMPFARR[$i]}
	COUNTER="$(($COUNTER+1))"
done

COUNTER=
NUMSTRING=${#FARR[@]}

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

clear

COUNTER=0

while true
do
	echo "Отсчёт строк начинается от "$lowbord
	echo "Всего строк: "$NUMSTRING
	echo "Идеальный порог ошибок: "$MAXERR
	echo "Осталось допустимых ошибок: "$NUMTRY
	echo "Правильных ответов: "$GOODQUEST
	echo "Допущено ошибок: "$ERRCOUNTER
	echo "Исправленно ошибок: "$SOLVEDERR
	echo "___________________________"

	if [[ $MISNUM -gt $INSERTCOUNT ]]
	then
		if [ $USERAND == NO ]
		then
			numinfun "Укажите номер строки:"
			USERNUMSTR="$retval"
			
			echo -e "Вы ввели: $USERNUMSTR\n"

			COUNTER=$(($COUNTER+1))

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

	elif [[ $MISNUM -eq $INSERTCOUNT ]]
	then
		# Insert question from not ansvered array
		for i in $(seq 0 $ERRCOUNTER)
		do
			if [[ ${ERRQ[$i]} == "OK" ]]
			then
				continue
			else
				USERNUMSTR=${ERRQ[$i]}
				echo "Произведена вставка вопроса на который был дан не верный ответ"
				echo -e "В качестве номера строки выбрано: "$USERNUMSTR'\n'
				COUNTER=$(($COUNTER+1))
				break
			fi
		done
	fi
	
	# Start QUESTION
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

		if [[ $MISNUM -gt $INSERTCOUNT ]]
		then
			# If this new good ansver
			GOODQUEST=$(($GOODQUEST+1))

			INSERTCOUNT=$(($INSERTCOUNT+1))
		elif [[ $MISNUM -eq $INSERTCOUNT ]]
		then
			# If this recheck, add as solved
			SOLVEDERR=$(($SOLVEDERR+1))

			# Exclude pointer from array
			for i in $(seq 0 $ERRCOUNTER)
			do
				# Search current value
				if [[ ${ERRQ[$i]} == $USERNUMSTR ]]
				then
					ERRQ[$i]="OK"
					break
				fi
			done

			if [ $NUMTRY -ne 0 ]
			then
				INSERTCOUNT=0
			fi
		fi

		continue
	fi

	echo -e "\tОтвет был таков: $(tput setaf 5)"$RIGHTANS"$(tput sgr 0)\n"

	# If this recheck MISS question, disable counter
	# and add pointer with error
	if [[ $MISNUM -gt $INSERTCOUNT ]]
	then
		if [ $NUMTRY -ne 0 ]
		then
			NUMTRY=$(($NUMTRY-1))
		fi

		if [ $NUMTRY -eq 0 ] && [[ $ERRCOUNTER -eq $SOLVEDERR ]]
		then
			echo "Вы ответили на все вопросы из заданого диапазона"
			echo -e "Выполнено завершение программы\n"
			exit 0
		fi

		# Point to not ansvered question
		ERRQ[$ERRCOUNTER]=$USERNUMSTR

		# After add pointer, shift to next item
		# increase error count
		ERRCOUNTER=$(($ERRCOUNTER+1))

		INSERTCOUNT=$(($INSERTCOUNT+1))

	# If this error occured while recheck exist error
	# not add error as dublicate
	elif [[ $MISNUM -eq $INSERTCOUNT ]]
	then
		# Disable counter if this rotate beyond of count trying
		if [ $NUMTRY -ne 0 ]
		then
			# If this question is not ansvered, reset counter
			# and after 3 normal question, call not ansvered question
			# controlled with this counter
			INSERTCOUNT=0
		fi
	fi

	echo -e "\n\n\nНажмите Enter для продолжения!\n"

	read

	clear

	tput sgr 0
done

