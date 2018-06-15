# 手动构建一个apk

项目是Android Studio新建的一个项目。因为引用到了constraint-layout库，所以找到aar解压了放到app的lib目录了，在Android的构建系统中，估计是groovy语法负责这个解压过程

系统环境是windows10

> 初衷是想脱离AS来使用aar库，主要用于给游戏接入不同渠道的sdk。但是结果发现完全做到不太可能。有些渠道的sdk不仅仅是改一下manifest，还需要改aaset文件，需要在特定的包下面新建特定名字的类,这种需要特别处理。     
不过如果是只改manifest的渠道sdk应该可以做到，用一个未签名的包，通过反编译工具添加相应的文件进去就可以了。

运行 buildapk.bat 会构建出一个apk，用的是Android和java自带的工具，aapt,javac,zipalign,apksigner等

中间会涉及到jar包的合并，资源文件的生成和打包等

存在的问题有：
* 没有处理AIDL
* 没有处理jni目录
* 没有处理asset目录（这个应该直接aapt a 加到apk里面就可以了）
* 没有涉及到Manifest的合并


遇到的主要的问题还是，合并aar到项目中，找了很多资料没有找到，只能按照自己的想法用土办法实现了。
* 对于jar包的合并，这个很容易，看java的jar工具语法就可以了
* 对于资源的合并，花了一段时间才想清楚aapt也可以把库目录的res指定生成进去的(-S参数指定多个目录)
* 对于主工程和库工程，都需要执行aapt生成R.java文件，然后编译成R.class然后合并到项目代码或者库的class中这么一个过程



通过这个过程，应该会对apk的构建过程会有更多的了解，比如，之前看美团的多渠道打包方案（新和旧），就有点不明不白的，现在看就比较清楚了


BuildConfig这个类是不一定需要的，只是gradle的配置文件，gradle读写build.gradle文件生成BuildConfig类，进而操作写入到apk的相关属性里面去

