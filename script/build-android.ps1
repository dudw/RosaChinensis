# 经期记录 App 安卓构建脚本
# 分别产出 armv7 (armeabi-v7a) 与 armv8 (arm64-v8a) 的 APK
# 用法: pwsh -File build-android.ps1 [-Mode debug|release] [-Output 路径] [-Flutter 路径]

[CmdletBinding()]
param(
  [ValidateSet("debug", "release")]
  [string]$Mode = "debug",
  [string]$Output = "",
  [string]$Flutter = "flutter"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent $ScriptDir
$AppDir    = $RepoRoot
$DistDir   = if ($Output) { $Output } else { Join-Path $RepoRoot "dist" }

# ABI 列表: armv7 = armeabi-v7a; armv8 = arm64-v8a
$AbiTargets = @(
  @{ Name = "armv7"; Gradle = "armeabi-v7a" },
  @{ Name = "armv8"; Gradle = "arm64-v8a" }
)

function Write-Step($msg) {
  Write-Host "`n==> $msg" -ForegroundColor Cyan
}

function Invoke-Safe($cmd, $argList) {
  Write-Host "    $cmd $($argList -join ' ')" -ForegroundColor DarkGray
  & $cmd @argList
  if ($LASTEXITCODE -ne 0) {
    throw "命令执行失败 exit=$LASTEXITCODE : $cmd $($argList -join ' ')"
  }
}

# 1. 校验工程目录
if (-not (Test-Path (Join-Path $AppDir "pubspec.yaml"))) {
  throw "未在 $AppDir 找到 pubspec.yaml"
}

# 2. 读取版本号
$pubspec = Get-Content (Join-Path $AppDir "pubspec.yaml") -Raw
if ($pubspec -match '(?m)^version:\s*([0-9.]+)(?:\+(\d+))?') {
  $VersionName = $Matches[1]
  $VersionCode = if ($Matches[2]) { $Matches[2] } else { "1" }
} else {
  $VersionName = "1.0.0"
  $VersionCode = "1"
}
Write-Step "版本 $VersionName+$VersionCode  构建类型 $Mode"

# 3. flutter pub get
Write-Step "执行 flutter pub get"
Push-Location $AppDir
try {
  Invoke-Safe $Flutter @("pub", "get")
}
finally {
  Pop-Location
}

# 4. 构建: --split-per-abi 按目标平台拆分 APK
Write-Step "构建 $Mode APK (armv7 + armv8)"
Push-Location $AppDir
try {
  # android-arm = armeabi-v7a (armv7), android-arm64 = arm64-v8a (armv8)
  $buildArgs = @(
    "build", "apk", "--$Mode",
    "--split-per-abi",
    "--target-platform=android-arm,android-arm64"
  )
  Invoke-Safe $Flutter $buildArgs
}
finally {
  Pop-Location
}

# 5. 定位产物并复制到 dist/
$ApkOutDir = Join-Path $AppDir "build\app\outputs\flutter-apk"
if (-not (Test-Path $ApkOutDir)) {
  $ApkOutDir = Join-Path $AppDir "build\app\outputs\apk\$Mode"
}
if (-not (Test-Path $ApkOutDir)) {
  throw "未找到 APK 产物目录: $ApkOutDir"
}

New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
Write-Step "收集产物到 $DistDir"

$found = @()
foreach ($abi in $AbiTargets) {
  $pattern = "*$($abi.Gradle)*$Mode*.apk"
  $apk = Get-ChildItem -Path $ApkOutDir -Filter $pattern -File -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1

  if (-not $apk) {
    $apk = Get-ChildItem -Path $ApkOutDir -Filter "*.apk" -File |
           Where-Object { $_.Name -like "*$($abi.Gradle)*" } |
           Sort-Object LastWriteTime -Descending | Select-Object -First 1
  }

  if ($apk) {
    $destName = "period_tracker-$VersionName-$($abi.Name)-$Mode.apk"
    $destPath = Join-Path $DistDir $destName
    Copy-Item -Path $apk.FullName -Destination $destPath -Force
    $size = [math]::Round(($apk.Length / 1MB), 2)
    Write-Host "  [OK] $($abi.Name) -> $destName ($size MB)" -ForegroundColor Green
    $found += $destName
  } else {
    Write-Warning "  [缺失] 未找到 $($abi.Name) ($($abi.Gradle)) 产物"
  }
}

# 6. 汇总
Write-Host "`n构建完成:" -ForegroundColor Cyan
foreach ($f in $found) {
  Write-Host "  - $(Join-Path $DistDir $f)"
}

if ($found.Count -lt $AbiTargets.Count) {
  Write-Host "`n提示: 部分 ABI 产物缺失, 可检查 build\app\outputs 目录" -ForegroundColor Yellow
  exit 1
}

exit 0
