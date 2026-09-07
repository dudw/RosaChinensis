# 默认 debug
pwsh -File build-android.ps1

# release 包
pwsh -File build-android.ps1 -Mode release

# 指定输出目录
pwsh -File build-android.ps1 -Mode release -Output D:\releases