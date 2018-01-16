BPKI: профиль инфраструктуры открытых ключей
============================================

[![Build Status](https://travis-ci.org/bcrypto/bpki.svg?branch=master)](https://travis-ci.org/bcrypto/bpki)

Что такое BPKI?
---------------

BPKI -- это профиль инфраструктуры открытых ключей (ИОК), рекомендуемый 
для использования в Республике Беларусь. BPKI определяет стороны ИОК, 
процессы взаимодействия сторон, протоколы взаимодействия. BPKI уточняет 
форматы объектов ИОК, унифицирует правила работы с конечными 
криптографическими устройствами ИОК.

Спецификация BPKI оформлена как проект государственного стандарта
СТБ 34.101.78. Принятие стандарта планируется в 2018 году.

Репозиторий bcrypto/bpki
------------------------

Репозиторий bcrypto/bpki, открытый на площадке
[http://github.com](http://github.com), является удобной платформой для
коллективного обсуждения и совершенствования BPKI и будущего стандарта СТБ
34.101.78.

В папке [spec](spec) размещаются исходные тексты спецификации BPKI. Тексты
оформлены как проект издательской системы
[LaTeX](https://ru.wikipedia.org/wiki/LaTeX). Сборка проекта выполняется
автоматически, всякий раз при внесении изменений.  В результате сборки
формируется файл `bpki.pdf`. Он сопровождает устойчивые редакции
спецификации, которые размещаются на вкладке
[Releases](https://github.com/bcrypto/bpki/releases).

В папке [demo](demo) находятся программы, моделирующие выпуск сертификатов.
Используется популярная криптографическая библиотека
[OpenSSL](https://github.com/openssl/openssl), дополненная плагином 
[bee2evp](https://github.com/bcrypto/bee2evp). Работа с командным 
интерфейсом OpenSSL[bee2evp] организована через командные файлы Windows.

В папке [dumpasn1b](dumpasn1b) размещена новая редакция популярной
программы [dumpasn1](http://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c),
предназначенной для дампа контейнеров АСН.1. Наша редакция dumpasn1,
названная dumpasn1b, корректно отображает русские и 
белорусские символы в строках типа `UTF8String`.

На вкладке [Issues](https://github.com/bcrypto/bpki/issues)
фиксируются замечания и предложения. 


