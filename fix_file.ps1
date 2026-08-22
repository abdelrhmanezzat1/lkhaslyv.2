$c = Get-Content 'lib/shared/widgets/app_order_card.dart' -Raw
$c = $c.TrimEnd("`r`n`"")
[IO.File]::WriteAllText('lib/shared/widgets/app_order_card.dart', $c + "`n", [System.Text.Encoding]::UTF8)