$apiKey = "AIzaSyBWL8amPfcGmXU0iHQUT3VCmwW9BxYd5L0"
$proj = "sri-gowri-ganesha"
$fid = "ganesha_2026"
$rn = "projects/$proj/databases/(default)/documents"
$d = "https://firestore.googleapis.com/v1/$rn"
$au = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey"
$cu = "$($d):commit"

$PASS = 0; $FAIL = 0
function CK($d,$c) { if ($c) { $script:PASS++; Write-Host "  PASS: $d" -ForegroundColor Green } else { $script:FAIL++; Write-Host "  FAIL: $d" -ForegroundColor Red } }

function api {
  param([string]$M, [string]$U, [string]$B="", [string]$T)
  $h = @{Authorization = "Bearer $T"}
  try {
    if ($B -ne "") { return Invoke-RestMethod -Uri $U -Method $M -Headers $h -ContentType "application/json" -Body $B }
    else { return Invoke-RestMethod -Uri $U -Method $M -Headers $h }
  } catch {
    Write-Host "  ERROR on $M $U" -ForegroundColor Red
    Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    try { $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Host "  Body: $($reader.ReadToEnd())" -ForegroundColor Red } catch { Write-Host "  (no body)" -ForegroundColor Red }
    return $null
  }
}

Write-Host "=== Festival Workflow Integration Test ===" -ForegroundColor Cyan

# 0. Auth
Write-Host "`n--- 0. Auth ---" -ForegroundColor Yellow
$ar = Invoke-RestMethod -Uri $au -Method POST -ContentType "application/json" -Body '{"returnSecureToken":true}'
$tk = $ar.idToken; if (-not $tk) { Write-Host "FATAL" -ForegroundColor Red; exit 1 }
Write-Host "  OK: $($tk.Substring(0,15))..." -ForegroundColor Green

$r = Get-Random -Minimum 10000 -Maximum 99999
$sid = "test_${r}_wf"
$c1 = "c${r}1"; $c2 = "c${r}2"; $c3 = "c${r}3"
$fuId = "fu_$r"; $eid = "exp_$r"

# Resource names (for commit bodies)
$trn = "$rn/targets/$sid"
$tr = "$d/targets/$sid"       # full URL for direct API
$c1n = "$trn/contributions/$c1"
$c2n = "$trn/contributions/$c2"
$c3n = "$trn/contributions/$c3"
$ts = "2026-06-01T00:00:00Z"

# ==================== 1. CREATE SPONSOR ====================
Write-Host "`n--- 1. Create sponsor ---" -ForegroundColor Yellow
$sf = @{festivalId=@{stringValue=$fid};name=@{stringValue="Test WF"};building=@{stringValue="B1"};area=@{stringValue="A1"};expectedAmount=@{integerValue="10000"};givenAmount=@{integerValue="0"};createdAt=@{timestampValue=$ts};updatedAt=@{timestampValue=$ts}}
$j1 = api -M PATCH -U $tr -B (@{fields=$sf} | ConvertTo-Json -Depth 5 -Compress) -T $tk
CK "Create sponsor" ($j1.fields.name.stringValue -eq "Test WF")

# ==================== 2. RECORD CONTRIBUTION +5000 (FieldValue.increment via transform) ====================
Write-Host "`n--- 2. Record +5000 (atomic batch) ---" -ForegroundColor Yellow
$w2 = @(@{transform=@{document=$trn;fieldTransforms=@(@{fieldPath="givenAmount";increment=@{integerValue="5000"}})}};@{update=@{name=$c1n;fields=@{type=@{stringValue="contribution"};amount=@{integerValue="5000"};note=@{stringValue="First payment"};recordedBy=@{stringValue="system"};createdAt=@{timestampValue="2026-06-01T10:00:00Z"};updatedAt=@{timestampValue="2026-06-01T10:00:00Z"}}}})
$j2 = api -M POST -U $cu -B (@{writes=$w2} | ConvertTo-Json -Depth 10 -Compress) -T $tk
CK "Batch: 2 writes" ($j2.writeResults.Count -eq 2)

# ==================== 3. SECOND CONTRIBUTION +3000 (simulating second device) ====================
Write-Host "`n--- 3. Record +3000 (2nd device) ---" -ForegroundColor Yellow
$w3 = @(@{transform=@{document=$trn;fieldTransforms=@(@{fieldPath="givenAmount";increment=@{integerValue="3000"}})}};@{update=@{name=$c2n;fields=@{type=@{stringValue="contribution"};amount=@{integerValue="3000"};note=@{stringValue="Second device"};recordedBy=@{stringValue="system"};createdAt=@{timestampValue="2026-06-01T11:00:00Z"};updatedAt=@{timestampValue="2026-06-01T11:00:00Z"}}}})
$j3 = api -M POST -U $cu -B (@{writes=$w3} | ConvertTo-Json -Depth 10 -Compress) -T $tk
CK "Batch2: 2 writes" ($j3.writeResults.Count -eq 2)

# ==================== 4. VERIFY TOTAL = 8000 ====================
Write-Host "`n--- 4. Verify total = 8000 ---" -ForegroundColor Yellow
$jv = api -M GET -U $tr -T $tk
$tl = [int]$jv.fields.givenAmount.integerValue
CK "5000 + 3000 = 8000" ($tl -eq 8000)

# ==================== 5. CORRECTION 8000 -> 7500 (delta = -500) ====================
Write-Host "`n--- 5. Correction 8000->7500 (delta=-500) ---" -ForegroundColor Yellow
$w5 = @(@{transform=@{document=$trn;fieldTransforms=@(@{fieldPath="givenAmount";increment=@{integerValue="-500"}})}};@{update=@{name=$c3n;fields=@{type=@{stringValue="correction"};amount=@{integerValue="-500"};note=@{stringValue="Discrepancy correction"};recordedBy=@{stringValue="system"};createdAt=@{timestampValue="2026-06-01T12:00:00Z"};updatedAt=@{timestampValue="2026-06-01T12:00:00Z"}}}})
$j5 = api -M POST -U $cu -B (@{writes=$w5} | ConvertTo-Json -Depth 10 -Compress) -T $tk
CK "Correction: 2 writes" ($j5.writeResults.Count -eq 2)
$jv5 = api -M GET -U $tr -T $tk
$tl5 = [int]$jv5.fields.givenAmount.integerValue
CK "Corrected total = 7500" ($tl5 -eq 7500)

# ==================== 6. VERIFY HISTORY ====================
Write-Host "`n--- 6. Verify contribution history ---" -ForegroundColor Yellow
$hq = @{parent=$trn;structuredQuery=@{from=@(@{collectionId="contributions"});orderBy=@(@{field=@{fieldPath="createdAt"};direction="DESCENDING"})}} | ConvertTo-Json -Depth 5 -Compress
$hist = api -M POST -U "$($tr):runQuery" -B $hq -T $tk
$types = @(); $amts = @()
if ($hist -is [array]) { foreach ($d in $hist) { if ($d.document) { $types += $d.document.fields.type.stringValue; $amts += [int]$d.document.fields.amount.integerValue } } }
CK "3 entries" ($types.Count -eq 3)
if ($types.Count -ge 3) {
  CK "[0]: correction" ($types[0] -eq "correction"); CK "[0] amt: -500" ($amts[0] -eq -500)
  CK "[1]: contribution" ($types[1] -eq "contribution"); CK "[1] amt: 3000" ($amts[1] -eq 3000)
  CK "[2]: contribution" ($types[2] -eq "contribution"); CK "[2] amt: 5000" ($amts[2] -eq 5000)
}

# ==================== 7-8. QR (SKIP) ====================
Write-Host "`n--- 7-8. QR: SKIP (Storage blob upload) ---" -ForegroundColor Gray

# ==================== 9. CREATE FOLLOW-UP ====================
Write-Host "`n--- 9. Create follow-up ---" -ForegroundColor Yellow
Write-Host "  DEBUG: d = [$d]" -ForegroundColor Gray
$fu = @{fields=@{festivalId=@{stringValue=$fid};sponsorId=@{stringValue=$sid};sponsorName=@{stringValue="Test WF"};followUpDate=@{timestampValue="2026-06-05T10:00:00Z"};amount=@{integerValue="5000"};note=@{stringValue="Balance follow-up"};status=@{stringValue="active"};createdAt=@{timestampValue="2026-06-01T13:00:00Z"}}} | ConvertTo-Json -Depth 5 -Compress
$j9 = api -M PATCH -U "$d/sponsor_followups/$fuId" -B $fu -T $tk
CK "Follow-up" ($j9.fields.sponsorName.stringValue -eq "Test WF")

# ==================== 10. COMPLETE FOLLOW-UP ====================
Write-Host "`n--- 10. Complete follow-up ---" -ForegroundColor Yellow
$fuUp = @{fields=@{status=@{stringValue="completed"};completedAt=@{timestampValue="2026-06-01T14:00:00Z"}}} | ConvertTo-Json -Depth 5 -Compress
$j10 = api -M PATCH -U "$d/sponsor_followups/$fuId?updateMask.fieldPaths=status&updateMask.fieldPaths=completedAt" -B $fuUp -T $tk
CK "Completed" ($j10.fields.status.stringValue -eq "completed")

# ==================== 11. ADD EXPENSE ====================
Write-Host "`n--- 11. Add expense ---" -ForegroundColor Yellow
$ex = @{fields=@{festivalId=@{stringValue=$fid};amount=@{integerValue="2000"};note=@{stringValue="Test expense"};date=@{timestampValue="2026-06-01T00:00:00Z"};createdAt=@{timestampValue="2026-06-01T15:00:00Z"}}} | ConvertTo-Json -Depth 5 -Compress
$j11 = api -M PATCH -U "$d/expenses/$eid" -B $ex -T $tk
CK "Expense = 2000" ([int]$j11.fields.amount.integerValue -eq 2000)

# ==================== 12. DASHBOARD METRICS ====================
Write-Host "`n--- 12. Dashboard metrics ---" -ForegroundColor Yellow
# Target list
$tq = @{structuredQuery=@{from=@(@{collectionId="targets"});where=@{fieldFilter=@{field=@{fieldPath="festivalId"};op="EQUAL";value=@{stringValue=$fid}}}}} | ConvertTo-Json -Depth 5 -Compress
$tgt = api -M POST -U "$($d):runQuery" -B $tq -T $tk
$inList = $false; if ($tgt -is [array]) { foreach ($t in $tgt) { if ($t.document -and $t.document.name -match $sid) { $inList = $true } } }
CK "Sponsor in targets list" $inList
# Expense list
$eq = @{structuredQuery=@{from=@(@{collectionId="expenses"});where=@{fieldFilter=@{field=@{fieldPath="festivalId"};op="EQUAL";value=@{stringValue=$fid}}}}} | ConvertTo-Json -Depth 5 -Compress
$exp = api -M POST -U "$($d):runQuery" -B $eq -T $tk
$inExp = $false; if ($exp -is [array]) { foreach ($e in $exp) { if ($e.document -and $e.document.name -match $eid) { $inExp = $true } } }
CK "Expense in expenses list" $inExp

# Summary
Write-Host "`n=======================================" -ForegroundColor Cyan
$col = if ($FAIL -eq 0) { "Green" } else { "Red" }
Write-Host "  $PASS passed, $FAIL failed" -ForegroundColor $col
Write-Host "=======================================" -ForegroundColor Cyan

# Cleanup
Write-Host "`n--- Cleanup ---" -ForegroundColor Yellow
try { Invoke-RestMethod -Uri $tr -Method DELETE -Headers @{Authorization = "Bearer $tk"} } catch {}
try { Invoke-RestMethod -Uri "$d/sponsor_followups/$fuId" -Method DELETE -Headers @{Authorization = "Bearer $tk"} } catch {}
try { Invoke-RestMethod -Uri "$d/expenses/$eid" -Method DELETE -Headers @{Authorization = "Bearer $tk"} } catch {}
Write-Host "  Done" -ForegroundColor Green
