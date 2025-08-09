function New-GuerrillaMailSession {
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $url = "https://api.guerrillamail.com/ajax.php?f=get_email_address&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $resp = Invoke-WebRequest -Uri $url -Method Get -WebSession $session
    $email = ($resp.Content | ConvertFrom-Json)

    $guerrillaSession = [PSCustomObject]@{
        Session = $session
        Email = $email.email_addr
        EmailTimestamp = $email.email_timestamp
    }

    return $guerrillaSession
}

function Get-MailAddress{
    # This function is now superseded by New-GuerrillaMailSession
    # It is kept for backward compatibility but will just create a new session.
    return New-GuerrillaMailSession
}

function Set-MailUser{
    Param(
       [Parameter(Mandatory=$true)]
       [PSCustomObject]$GuerrillaSession,
       [Parameter(Mandatory=$true)]
       [string]$user,
       [Parameter(Mandatory=$true)]
       [ValidateSet("sharklasers.com","guerrillamail.com","guerrillamail.org","guerrillamail.net","grr.la")]
       [string]$domain
    ) #end param
    $url = "https://api.guerrillamail.com/ajax.php?f=set_email_user&email_user="+$user+"&domain="+$domain+"&lang=en&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $resp = Invoke-WebRequest -Uri $url -Method Get -WebSession $GuerrillaSession.Session | ConvertFrom-Json
    $GuerrillaSession.Email = $resp.email_addr
    $GuerrillaSession.EmailTimestamp = $resp.email_timestamp
    return $resp
}

function Get-Mail{
    Param(
       [Parameter(Mandatory=$true)]
       [PSCustomObject]$GuerrillaSession,
       [Int]$seq_no = 0
    ) #end param
    $url_check = "https://api.guerrillamail.com/ajax.php?f=check_email&seq="+$seq_no+"&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $obj_checkmail = Invoke-RestMethod $url_check -Method Get -WebSession $GuerrillaSession.Session
    return $obj_checkmail
}

function Get-MailContent{
    Param(
       [Parameter(Mandatory=$true)]
       [PSCustomObject]$GuerrillaSession,
       [Parameter(Mandatory=$true)]
       [string]$mail_id
    ) #end param
    $url_fetch = "https://api.guerrillamail.com/ajax.php?f=fetch_email&email_id="+$mail_id+"&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $obj_fetchmail = Invoke-RestMethod $url_fetch -Method Get -WebSession $GuerrillaSession.Session
    return $obj_fetchmail
}

function Get-MailList{
    Param(
       [Parameter(Mandatory=$true)]
       [PSCustomObject]$GuerrillaSession,
       [Int]$offset = 0,
       [Int]$seq_no = 0
    ) #end param
    $url_check = "https://api.guerrillamail.com/ajax.php?f=get_email_list&seq="+$seq_no+"&offset="+$offset+"&ip=127.0.0.1&agent=Mozilla_foo_bar"
    $obj_checkmail = Invoke-RestMethod $url_check -Method Get -WebSession $GuerrillaSession.Session
    return $obj_checkmail.list
}

function Get-MailFor{
    Param(
       [Parameter(Mandatory=$true)]
       [PSCustomObject]$GuerrillaSession,
       [Parameter(Mandatory=$true)]
       [string]$user,
       [Parameter(Mandatory=$true)]
       [ValidateSet("sharklasers.com","guerrillamail.com","guerrillamail.org","guerrillamail.net","grr.la")]
       [string]$domain
    ) #end param
    Set-MailUser -GuerrillaSession $GuerrillaSession -user $user -domain $domain
    "Mail for email: "+$GuerrillaSession.Email
    $mail = Get-Mail -GuerrillaSession $GuerrillaSession
    return $mail.list
}
