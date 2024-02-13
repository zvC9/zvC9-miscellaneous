#!/bin/bash

echo Обновление. ЗАКРОЙТЕ ВСЕ ПРОГРАММЫ, выключите все виртуальные машины
echo и не открывайте \(и не запускайте\) до конца обновления и перезагрузки
echo -en Продолжить? \(\"yes\" \(без кавычек\) Enter = продолжить, просто Enter = отменить\)\\nОтвет:\ 
read varAnswer
if test "x$varAnswer" = "xyes" ; then
	sync
	sync
	apt update ; sync ; sync
	mintupdate-cli upgrade ; echo \$\?=$? ; sync ; sync

	apt update ; sync ; sync 
	mintupdate-cli upgrade ; echo \$\?=$? ; sync ; sync

	echo -e \\n\\n\\nОБНОВЛЕНО
	echo ПЕРЕЗАГРУЗИТЕ КОМПЬЮТЕР
	echo Enter = выход
	read varTemp
else
 echo "Отменено. Enter = выход"
 read varTemp
fi

