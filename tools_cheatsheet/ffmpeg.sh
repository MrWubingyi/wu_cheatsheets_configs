##############################################################################
# FFMPEG CHEATSHEET (中文速查表)  -  by skywind (created on 2020/09/20)
# Version: 3, Last Modified: 2020/09/21 14:37
# https://github.com/skywind3000/awesome-cheatsheets
##############################################################################


##############################################################################
# 基础参数
##############################################################################

-codecs                                                     # 列出可用编码
-formats                                                    # 列出支持的格式
-protocols                                                  # 列出支持的协议
-i input.mp4                                                # 指定输入文件
-c:v libx264                                                # 指定视频编码
-c:a aac                                                    # 指定音频编码
-vcodec libx264                                             # 旧写法
-acodec aac                                                 # 旧写法
-fs SIZE                                                    # 指定文件大小
-f rtp                                                      # 指定输出格式

##############################################################################
# 音频参数
##############################################################################

-aq QUALITY                                                 # 音频质量，编码器相关
-ar 44100                                                   # 音频采样率
-ac 1                                                       # 音频声道数量
-an                                                         # 禁止音频
-vol 512                                                    # 改变音量为 200%


##############################################################################
# 视频参数
##############################################################################

-aspect RATIO                                               # 长宽比 4:3, 16:9
-r RATE                                                     # 每秒帧率
-s WIDTHxHEIGHT                                             # 视频尺寸：640x480
-vn                                                         # 禁用视频


##############################################################################
# 码率设置
##############################################################################

-b:v 1M                                                     # 设置视频码率 1mbps/s
-b:a 1M                                                     # 设置音频码率 1mbps/s


##############################################################################
# 音视频转码
##############################################################################

ffmpeg -i input.mov output.mp4                                    # 转码为 MP4
ffmpeg -i input.mp4 -vn -c:a copy output.aac                      # 提取音频
ffmpeg -i input.mp4 -vn -c:a mp3 output.mp3                       # 提取音频并转码
ffmpeg -i input.mov -c:v libx264 -c:a aac -2 out.mp4              # 指定编码参数
ffmpeg -i input.mov -c:v libvpx -c:a libvorbis out.webm           # 转换 webm
ffmpeg -i input.mp4 -ab 56 -ar 44100 -b 200 -f flv out.flv        # 转换 flv
ffmpeg -i input.mp4 -an animated.gif                              # 转换 GIF
ffmpeg -y -i input.h263 -c:v copy out.mp4                         # 转换h263
ffmpeg -f g723_1 -ac 1 -y -i input.g723 out.wav                   # 转换g723
ffmpeg -y -i input.h261 -c:v copy -f avi out.avi                  # 转换h261->avi
ffmpeg -f s16le -ar 8000 -ac 1 -i input.g728 -c:a copy out.wav    # 转换g728->wav


##############################################################################
# 切分视频
##############################################################################

ffmpeg -i input.mp4 -ss 0 -t 60 first-1-min.mp4             # 切割开头一分钟
ffmpeg -i input.mp4 -ss 60 -t 60 second-1-min.mp4           # 一分钟到两分钟
ffmpeg -i input.mp4 -ss 00:01:23.000 -t 60 first-1-min.mp4  # 另一种时间格式

##############################################################################
# 合并视频
##############################################################################
# 两视频拼接
ffmpeg -y -i input1.mp4 -i input2.mp4 -filter_complex \"[0:v]pad=iw*2:ih[int];[int][1:v]overlay=W/2:0[vid]\" -map \"[vid]\" -c:v libx264 -crf 23 -preset veryfast out.mp4
# 音视频拼接
ffmpeg -i input1.h264 -i input2.wav  -c:v copy -c:a aac -strict experimental out.mp4
# 两音频拼接
ffmpeg -i input1.wav -i input2.wav -filter_complex amix=inputs=2:duration=first:dropout_transition=2 out.wav
# 两视频一音频
ffmpeg -y -i input1.h264 -i input2.h264 -i input3.wav -filter_complex \"[0:v][1:v]hstack=inputs=2[v];[2:a]anull[a];[v][a]amix=inputs=2\" -map \"[v]\" -map \"[a]\" out.mp4
# 一视频两音频
ffmpeg -y -i input1.h264 -i input2.wav -i input3.wav -filter_complex \"[1:a][2:a]amix=inputs=2[a]\" -map 0:v -map \"[a]\" out.mp4
# 两视频两音频
ffmpeg -y -i input1.h264 -i input2.h264 -i input1.wav -i input2.wav -filter_complex \"[0:v][1:v]hstack=inputs=2[v];[2:a][3:a]amerge=inputs=2[a]\" -map \"[v]\" -map \"[a]\" out.mp4

##############################################################################
# 视频尺寸
##############################################################################

ffmpeg -i input.mp4 -vf "scale=640:320" output.mp4          # 视频尺寸缩放
ffmpeg -i input.mp4 -vf "crop=400:300:10:10" output.mp4     # 视频尺寸裁剪


##############################################################################
# 其他用法
##############################################################################

ffmpeg -i sub.srt sub.ass                                   # 字幕格式转换
ffmpeg -i input.mp4 -vf ass=sub.ass out.mp4                 # 烧录字幕进视频
ffmpeg -i "<url>" out.mp4                                   # 下载视频
ffmpeg -re -stream_loop -1 -i h261.mp4 -c:v h261   -f_strict experimental -an -f rtsp  rtsp://192.168.105.51:8554/stream # ffmpeg 推流:


# 推流与播放(h264 + rtp)
ffmpeg -re -i Mercury_Records.mp4 -c:v libx264 -bsf:v h264_mp4toannexb -an -f rtp  rtp://192.168.106.42:1234?pkt_size=1316

# 推流与播放(h264 + udp)
ffmpeg -re -i Mercury_Records.mp4 -c:v libx264 -bsf:v h264_mp4toannexb -an -f h264 udp://192.168.106.42:1234?pkt_size=1316

# 推流与播放(ts + udp)
ffmpeg -re -i Mercury_Records.mp4 -c:v libx264 -bsf:v h264_mp4toannexb -an -f mpegts udp://192.168.106.42:1234?pkt_size=1316

# 推流与播放(ts + rtp)
ffmpeg -re -i Mercury_Records.mp4 -c:v libx264 -bsf:v h264_mp4toannexb -an -f rtp_mpegts  rtp://192.168.106.42:1234?pkt_size=1316

##############################################################################
# 组合用法
##############################################################################

# 给 gif 加上静音音轨并转换成 mp4
ffmpeg -f lavfi -i anullsrc -i in.gif -c:v libx264 -c:a aac -shortest out.mp4

# 给 gif 加上静音音轨并转换成 mp4，兼容手机播放
ffmpeg -f lavfi -i anullsrc -i in.gif -c:v libx264 -c:a aac -shortest \
       -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" out.mp4


##############################################################################
# 相关资源
##############################################################################

https://cheatography.com/thetartankilt/cheat-sheets/ffmpeg/
http://qwinff.github.io/



