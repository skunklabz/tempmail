$header = @{"ApiToken"="9fc104bfc7f71e7e1aef5479eb87ebe81e651432377a60953d82ff0de7b99c2e"}

function Get-MailAddress{
    $url = "https://api.guerrillamail.com/ajax.php?f=get_email_address&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $resp = Invoke-WebRequest -Uri $url -Method Get | ConvertFrom-Json | Format-List
    return $resp
}

function Set-MailUser{
    Param(
   [Parameter(Mandatory=$true)]
   [string]$user,
   [Parameter(Mandatory=$true)]
   [ValidateSet("sharklasers.com","guerrillamail.com","guerrillamail.org","guerrillamail.net","grr.la")]
   [string]$domain
    ) #end param
    $url = "https://api.guerrillamail.com/ajax.php?f=set_email_user&email_user="+$user+"&domain="+$domain+"&lang=en&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $header = @{"ApiToken"="9fc104bfc7f71e7e1aef5479eb87ebe81e651432377a60953d82ff0de7b99c2e"}
    $resp = Invoke-WebRequest -Uri $url -Method Get -Headers $header | ConvertFrom-Json
    return $resp
}

function Get-Mail{
    Param(
   [Parameter(Mandatory=$true)]
   [string]$sid_token,
   [Int]$seq_no
    ) #end param
    $url_check = "http://api.guerrillamail.com/ajax.php?f=check_email&sid_token="+$sid_token+"&seq="+$seq_no+"&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $obj_checkmail = Invoke-RestMethod $url_check -Method Get
    return $obj_checkmail
}

function Fetch-Mail{
    Param(
   [Parameter(Mandatory=$true)]
   [string]$sid_token,
   [string]$mail_id
    ) #end param
    $url_fetch = "http://api.guerrillamail.com/ajax.php?f=fetch_email&sid_token="+$sid_token+"&email_id="+$mail_id+"&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $obj_fetchmail = Invoke-RestMethod $url_fetch -Method Get
    return $obj_fetchmail
}

function Get-MailList{
    Param(
   [Parameter(Mandatory=$true)]
   [string]$sid_token,
   [Int]$offset,
   [Int]$seq_no
    ) #end param
    $url_check = "http://api.guerrillamail.com/ajax.php?f=check_email&sid_token="+$sid_token+"&seq="+$seq_no+"&offset="+$offset+"&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $obj_checkmail = Invoke-RestMethod $url_check -Method Get
    return $obj_checkmail.list | ConvertFrom-Json
}

function Get-MailFor{
    Param(
   [Parameter(Mandatory=$true)]
   [string]$user,
   [Parameter(Mandatory=$true)]
   [ValidateSet("sharklasers.com","guerrillamail.com","guerrillamail.org","guerrillamail.net","grr.la")]
   [string]$domain
    ) #end param
    $url = "https://api.guerrillamail.com/ajax.php?f=set_email_user&email_user="+$user+"&domain="+$domain+"&lang=en&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $resp = Invoke-WebRequest -Uri $url -Method Get -Headers $header | ConvertFrom-Json
    "Mail for sid_token: "+$resp.sid_token
    $url_check = "http://api.guerrillamail.com/ajax.php?f=check_email&sid_token="+$resp.sid_token+"&seq=0&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $obj_checkmail = Invoke-RestMethod $url_check -Method Get
    return $obj_checkmail.list | Format-Table
}
