@ECHO build apk use cmd

set proj_path=D:\git_proj\manuallyBuild
set android_path=D:\Android\Sdk\platforms\android-27\android.jar
set library_path=app\libs\constraint-layout-1.1.1

::处理libs文件夹目录的aar库，主要是生成R文件然后编译成.class合并到jar包里
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

::处理主目录下的文件
cd %proj_path%

::生成R文件
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

::生成apk并添加资源文件

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

::javac处理R.java和项目代码里的java文件,生成class文件
javac ^
-encoding UTF-8 ^
-bootclasspath %android_path%  ^
-d ./output ^
-classpath %android_path% ^
gen\com\xckoo\test\androidpack\*.java ^
app\src\main\java\com\xckoo\test\androidpack\*.java 

::与库的jar文件解压到同一个目录
move %library_path%\new.jar output
cd output
jar xvf new.jar

del new.jar
cd ..

::生成dex文件
call dx --dex --output=./output/classes.dex ./output

::添加dex到apk
cd ./output
aapt a ./testbuid.apk classes.dex

::对齐优化
zipalign -v -p 4 testbuid.apk aligned.apk

::删除中间文件
rd /s/q com
del/f/s/q testbuid.apk
del/f/s/q classes.dex
rd /s/q android
rd /s/q META-INF

cd ..

::签名
call apksigner sign --ks debug.keystore --ks-pass pass:android --key-pass pass:android ./output/aligned.apk

rd /s/q gen

pause