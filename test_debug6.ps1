$apiKey = "AIzaSyBWL8amPfcGmXU0iHQUT3VCmwW9BxYd5L0"
$proj = "sri-gowri-ganesha"
$fid = "ganesha_2026"
$rn = "projects/$proj/databases/(default)/documents"
$d = "https://firestore.googleapis.com/v1/$rn"
$au = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey"

$ar = Invoke-RestMethod -Uri $au -Method POST -ContentType "application/json" -Body '{"returnSecureToken":true}'
$tk = $ar.idToken; Write-Host "Auth OK"

$r = Get-Random -Minimum 10000 -Maximum 99999
$sid = "test_${r}_wf"; $c1 = "c${r}1"
$tr = "$d/targets/$sid"
$trn = "$rn/targets/$sid"; $c1n = "$trn/contributions/$c1"
$ts = "2026-06-01T00:00:00Z"

# Create sponsor + add contribution
$sf = @{festivalId=@{stringValue=$fid};name=@{stringValue="Test"};building=@{stringValue="B"};area=@{stringValue="A"};expectedAmount=@{integerValue="10000"};givenAmount=@{integerValue="0"};createdAt=@{timestampValue=$ts};updatedAt=@{timestampValue=$ts}}
Invoke-RestMethod -Uri $tr -Method PATCH -Headers @{Authorization="Bearer $tk"} -ContentType "application/json" -Body (@{fields=$sf} | ConvertTo-Json -Depth 5 -Compress) | Out-Null
$w = @(@{transform=@{document=$trn;fieldTransforms=@(@{fieldPath="givenAmount";increment=@{integerValue="500"}})}};@{update=@{name=$c1n;fields=@{type=@{stringValue="contribution"};amount=@{integerValue="500"};note=@{stringValue="test"};recordedBy=@{stringValue="system"};createdAt=@{timestampValue=$ts};updatedAt=@{timestampValue=$ts}}}})
Invoke-RestMethod -Uri "$($d):commit" -Method POST -Headers @{Authorization="Bearer $tk"} -ContentType "application/json" -Body (@{writes=$w} | ConvertTo-Json -Depth 10 -Compress) | Out-Null
Write-Host "Data created"

# Query subcollection via parent document: $tr:runQuery (NOT $tr/contributions:runQuery)
$url = "$($tr):runQuery"
Write-Host "URL: $url"

# Use parent in body to scope to the contributions subcollection
$hq = @{
  parent = $trn
  structuredQuery = @{
    from = @(@{collectionId="contributions"})
    orderBy = @(@{field=@{fieldPath="createdAt"};direction="DESCENDING"})
  }
} | ConvertTo-Json -Depth 5 -Compress
Write-Host "Query: $hq" -ForegroundColor Gray

try {
  $r = Invoke-RestMethod -Uri $url -Method POST -Headers @{Authorization="Bearer $tk"} -ContentType "application/json" -Body $hq
  $count = ($r | Measure-Object).Count
  Write-Host "OK: $count results" -ForegroundColor Green
  foreach ($item in $r) { if ($item.document) { Write-Host "  type=$($item.document.fields.type.stringValue) amt=$($item.document.fields.amount.integerValue)" } }
} catch {
  Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
  try { $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Host "Body: $($reader.ReadToEnd())" -ForegroundColor Red } catch {}
}

try { Invoke-RestMethod -Uri $tr -Method DELETE -Headers @{Authorization="Bearer $tk"} } catch {}
