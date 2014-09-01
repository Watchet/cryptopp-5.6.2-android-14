Crypto++ 5.6.2 (revision 541) built for Android-14 API, ARMv7 and STLport using the R9 NDK and arm-linux-androideabi-4.8 toolchain. The ZIP includes the headers, libcryptopp.so and libcryptopp.a.

The library use STLport because the STLport has a permissive, BSD style license. If you switch to GNU libstdc++, then you might encounter uncomfortable licensing terms. 

If you only want to include, compile, and link, then only download cryptopp-5.6.2-android-14.zip. It has everything you need for an Eclipse or command line project. Unzip the ZIP archive and place it in a convenient location. Use unzip -a to ensure CRLF are handled properly. /usr/local/cryptopp-android-14/ is a good location since it is world readable and write protected.

The additional files provided in cryptopp-mobile.zip are used to update the standard Crypto++ distribution and build the libcryptopp.so and libcryptopp.a libraries for Android. Place them in the same directory as Crypto++ source files (overwriting the original files). With the files in place, then run `. ./setenv-android.sh` (note the leading dot to ensure the changes affect the current shell). Then run `make static dynamic` as usual. If you don't care about building libcryptopp.so or libcryptopp.a yourself, then ignore the additional files.

When you create your Java class that uses your native library, be sure to:

    static {
		System.loadLibrary("stlport_shared");
		System.loadLibrary("cryptopp");
        System.loadLibrary("mylibrary");
	}
	
When you build your APK, be sure to place `libstlport_shared.so`, `libcryptopp.so` and `libmylibrary.so` in the `<project dir>/libs/armeabi/` folder. Also be sure to link your `libmylibrary.so` with `libstlport_shared.so`.

See http://www.cryptopp.com/wiki/Android_(Command_Line) for details on how the environment was set, how the library was built and how to use the library in an Eclipse project. If you have questions, then ask on the Crypto++ Users group at https://groups.google.com/forum/#!forum/cryptopp-users.