@ECHO build apk use cmd

set proj_path=D:\git_proj\manuallyBuild
set android_path=D:\Android\Sdk\platforms\android-27\android.jar
set library_path=app\libs\constraint-layout-1.1.1

::����libs�ļ���Ŀ¼��aar�⣬��Ҫ������R�ļ�Ȼ������.class�ϲ���jar����
cd %library_path%
mkdir gen

aapt package -f ^
-M AndroidManifest.xml ^
-I %android_path% ^
-S res ^
-J gen ^
-m

mkdir output

javac ^
-encoding UTF-8 ^
-bootclasspath %android_path%  ^
-classpath %android_path% ^
-d output ^
gen\android\support\constraint\*.java

cd output

jar xvf ..\libs\*.jar
jar xvf ..\classes.jar
jar cvf new.jar android

copy /Y new.jar ..
cd ..

rd /s/q gen
rd /s/q output

::������Ŀ¼�µ��ļ�
cd %proj_path%

::����R�ļ�
mkdir gen
aapt package -f ^
-M app\src\main\AndroidManifest.xml ^
-I %android_path% ^
-S app\src\main\res ^
-S %library_path%\res ^
--auto-add-overlay ^
-J gen ^
-m

mkdir output

::����apk�������Դ�ļ�

aapt package -f ^
-M app\src\main\AndroidManifest.xml ^
-I %android_path% ^
-S app\src\main\res ^
-S %library_path%\res ^
--auto-add-overlay ^
--min-sdk-version 16 ^
--target-sdk-version 21 ^
--version-code 1 ^
--version-name hello ^
-F ./output/testbuid.apk

::javac����R.java����Ŀ�������java�ļ�,����class�ļ�
javac ^
-encoding UTF-8 ^
-bootclasspath %android_path%  ^
-d ./output ^
-classpath %android_path% ^
gen\com\xckoo\test\androidpack\*.java ^
app\src\main\java\com\xckoo\test\androidpack\*.java 

::����jar�ļ���ѹ��ͬһ��Ŀ¼
move %library_path%\new.jar output
cd output
jar xvf new.jar

del new.jar
cd ..

::����dex�ļ�
call dx --dex --output=./output/classes.dex ./output

::���dex��apk
cd ./output
aapt a ./testbuid.apk classes.dex

::�����Ż�
zipalign -v -p 4 testbuid.apk aligned.apk

::ɾ���м��ļ�
rd /s/q com
del/f/s/q testbuid.apk
del/f/s/q classes.dex
rd /s/q android
rd /s/q META-INF

cd ..

::ǩ��
call apksigner sign --ks debug.keystore --ks-pass pass:android --key-pass pass:android ./output/aligned.apk

rd /s/q gen

pause