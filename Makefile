default:
	@./dmake desktop
	@make -C build
android:
	@./dmake android
	@make -C build_android

clean: desktop_clean
dclean: desktop_dclean
stdddclean: desktop_stddclean
stdlibclean: desktop_stdlibclean


desktop_dclean:
	@make -C build dclean
android_dclean:
	@make -C build_android dclean

desktop_stdlibclean:
	@make -C build stdlibclean
android_stdlibclean:
	@make -C build_android stdlibclean

desktop_stddclean:
	@make -C build stddclean
android_stddclean:
	@make -C build_android stddclean

desktop_clean:
	@make -C build clean
android_clean:
	@make -C build_android clean
