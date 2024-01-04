# 在makefile中链接asan
LDLIBS += -static-libasan
CFLAGS += -O0 -fsanitize=address -fno-omit-frame-pointer -static-libasan



# 对单独的文件加asan监测
dpi_sip.o: CFLAGS += -fsanitize=address -fno-omit-frame-pointer -static-libasan
LDLIBS += -lasan


#混合编译c与c++
# c++ 源码单独指定编译方式
dpi_scan_main_cc.o: dpi_scan_main_cc.c
	mkdir -p input/scan
	g++ -x c++ $(CXXFLAGS) -o $@ -c $<

dpi_wxpay_manager.o: dpi_wxpay_manager.c
	g++ -x c++ $(CXXFLAGS) -o $@ -c $< -std=c++11 -lpthread