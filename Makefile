default:
	@./dmake desktop
	@make -C build
android:
	@./dmake android
	@make -C build_android

clean: desktop_clean
desktop_clean:
	@make -C build clean
android_clean:
	@make -C build_android clean
