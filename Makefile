default:
	@./dmake desktop
	@make -C build
android:
	@./dmake android
	@make -C build_android

clean: desktop_clean
dclean: desktop_dclean
desktop_dclean:
	@make -C build dclean
android_dclean:
	@make -C build dclean
desktop_clean:
	@make -C build clean
android_clean:
	@make -C build_android clean
