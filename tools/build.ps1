param(
    [string]$DevEcoHome = $env:DEVECO_HOME,
    [ValidateSet("main", "test")][string]$Target = "main"
)
$ErrorActionPreference = "Stop"
if (-not $DevEcoHome) {
    throw 'Pass -DevEcoHome with your DevEco Studio installation directory, or set DEVECO_HOME.'
}
$devEcoRoot = (Resolve-Path -LiteralPath $DevEcoHome).Path
$projectRoot = Split-Path -Parent $PSScriptRoot
$node = Join-Path $devEcoRoot 'tools\node\node.exe'
$ohpm = Join-Path $devEcoRoot 'tools\ohpm\bin\ohpm.bat'
$hvigor = Join-Path $devEcoRoot 'tools\hvigor\bin\hvigorw.js'
foreach ($tool in @($node, $ohpm, $hvigor)) {
    if (-not (Test-Path -LiteralPath $tool)) { throw "Missing DevEco tool: $tool" }
}
$oldSdk = $env:DEVECO_SDK_HOME
$oldJava = $env:JAVA_HOME
$oldNode = $env:NODE_HOME
$oldPath = $env:PATH
Push-Location -LiteralPath $projectRoot
try {
    $env:DEVECO_SDK_HOME = Join-Path $devEcoRoot 'sdk'
    $env:JAVA_HOME = Join-Path $devEcoRoot 'jbr'
    $env:NODE_HOME = Split-Path -Parent $node
    $env:PATH = "$env:NODE_HOME;$env:PATH"
    & $ohpm install --all
    if ($LASTEXITCODE -ne 0) { throw "ohpm install failed ($LASTEXITCODE)" }
    $module = if ($Target -eq 'test') { 'entry@ohosTest' } else { 'entry@default' }
    & $node $hvigor --mode module -p product=default -p "module=$module" assembleHap --no-daemon
    if ($LASTEXITCODE -ne 0) { throw "HAP build failed ($LASTEXITCODE)" }
    Write-Host 'Build complete. Unsigned HAPs require your own debug signing before device installation.'
    if ($Target -eq 'test') { Write-Host 'Test HAP built only; instrument tests have NOT been executed.' }
} finally {
    Pop-Location
    $env:DEVECO_SDK_HOME = $oldSdk
    $env:JAVA_HOME = $oldJava
    $env:NODE_HOME = $oldNode
    $env:PATH = $oldPath
}
