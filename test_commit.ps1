$apiKey = "AIzaSyBWL8amPfcGmXU0iHQUT3VCmwW9BxYd5L0"
$proj = "sri-gowri-ganesha"
$fid = "ganesha_2026"
# Resource name prefix (NOT full URL) for commit body fields
$rn = "projects/$proj/databases/(default)/documents"
$d = "https://firestore.googleapis.com/v1/$rn"
$au = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey"
$cu = "$($d):commit"

$PASS = 0; $FAIL = 0
function CK($d,$c) { if ($c) { $script:PASS++; Write-Host "  PASS: $d" } else { $script:FAIL++; Write-Host "  FAIL: $d" } }

function api {
  param([string]$M, [string]$U, [string]$B="", [string]$T)
  $h = @{Authorization = "Bearer $T"}
  try {
    if ($B -ne "") { return Invoke-RestMethod -Uri $U -Method $M -Headers $h -ContentType "application/json" -Body $B }
    else { return Invoke-RestMethod -Uri $U -Method $M -Headers $h }
  } catch {
    try { $e = ($_.ErrorDetails | ConvertFrom-Json).error.message } catch { $e = $_.Exception.Message }
    Write-Host "  ERROR: $e" -ForegroundColor Red; return $null
  }
}

Write-Host "=== Debug Commit ===" -ForegroundColor Cyan

# Auth
$ar = Invoke-RestMethod -Uri $au -Method POST -ContentType "application/json" -Body '{"returnSecureToken":true}'
$tk = $ar.idToken; Write-Host "  Auth OK" -ForegroundColor Green

$r = Get-Random -Minimum 10000 -Maximum 99999
$sid = "test_${r}_wf"; $c1 = "c${r}1"
$tr = "$d/targets/$sid"        # full URL for API calls
$trn = "$rn/targets/$sid"      # resource name for commit body
$c1n = "$trn/contributions/$c1"
$ts = "2026-06-01T00:00:00Z"

# 1. Create sponsor
Write-Host "`n1. Create sponsor ---" -ForegroundColor Yellow
$sf = @{festivalId=@{stringValue=$fid};name=@{stringValue="Test WF"};building=@{stringValue="B1"};area=@{stringValue="A1"};expectedAmount=@{integerValue="10000"};givenAmount=@{integerValue="0"};createdAt=@{timestampValue=$ts};updatedAt=@{timestampValue=$ts}}
api -M PATCH -U $tr -B (@{fields=$sf} | ConvertTo-Json -Depth 5 -Compress) -T $tk | Out-Null
CK "Created" $true

# 2. Commit transform + update
Write-Host "`n2. Commit (transform + update) ---" -ForegroundColor Yellow
$w2 = @(@{transform=@{document=$trn;fieldTransforms=@(@{fieldPath="givenAmount";increment=@{integerValue="5000"}})}};@{update=@{name=$c1n;fields=@{type=@{stringValue="contribution"};amount=@{integerValue="5000"};note=@{stringValue="First"};recordedBy=@{stringValue="system"};createdAt=@{timestampValue="2026-06-01T10:00:00Z"};updatedAt=@{timestampValue="2026-06-01T10:00:00Z"}}}})
$b = @{writes=$w2} | ConvertTo-Json -Depth 10 -Compress
$r2 = api -M POST -U $cu -B $b -T $tk
if ($r2) { CK "Write results: $($r2.writeResults.Count)" ($r2.writeResults.Count -eq 2) }

# 3. Verify
Write-Host "`n3. Verify ---" -ForegroundColor Yellow
$jv = api -M GET -U $tr -T $tk
$tl = [int]$jv.fields.givenAmount.integerValue; Write-Host "  Total: $tl" -ForegroundColor Gray
CK "Total = 5000" ($tl -eq 5000)
$jc = api -M GET -U "$d/targets/$sid/contributions/$c1" -T $tk
CK "Contrib exists" ($jc -and $jc.fields.type.stringValue -eq "contribution")

# Cleanup
try { Invoke-RestMethod -Uri $tr -Method DELETE -Headers @{Authorization = "Bearer $tk"} } catch {}
Write-Host "`nDone: $PASS passed, $FAIL failed" -ForegroundColor $(if ($FAIL -eq 0){"Green"}else{"Red"})
