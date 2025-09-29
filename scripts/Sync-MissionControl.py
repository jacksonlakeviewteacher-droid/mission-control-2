param(
  [switch]$Preview,  # -Preview for dry-run
  [string]$Source = "G:\My Drive\Mission-Control-2",
  [string]$Dest   = "C:\Dev\Mission-Control-2",
  [string]$Log    = "C:\Dev\mc2_sync.log"
)

$flags = @(
  '/MIR', '/R:2', '/W:2', '/XJ',
  '/XD', '.git', 'node_modules', 'dist', 'build', '.cache',
  '/XF', 'Thumbs.db', 'desktop.ini',
  '/COPY:DAT', '/DCOPY:DAT', '/NFL', '/NDL', '/NP',
  "/LOG:$Log"
)

if ($Preview) { $flags += '/L'; $Log = $Log -replace '\.log$', '_preview.log' }

robocopy $Source $Dest $flags
$exit = $LASTEXITCODE
Write-Host "Robocopy exit code: $exit (0,1,2 are success-ish)"
