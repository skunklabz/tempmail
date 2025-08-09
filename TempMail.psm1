<#
.SYNOPSIS
    Creates a new session with the Guerrilla Mail API and gets a new temporary email address.

.DESCRIPTION
    This function initializes a new session with Guerrilla Mail. It creates a WebRequestSession object to handle cookies and retrieves an initial temporary email address.
    This session object is required by all other functions in this module to interact with the API.

.EXAMPLE
    PS C:\> $session = New-GuerrillaMailSession
    PS C:\> $session.Email
    abcdef@guerrillamailblock.com

.RETURNS
    A PSCustomObject containing the WebRequestSession, the email address, and the creation timestamp of the email address. Returns $null on failure.
#>
function New-GuerrillaMailSession {
    [CmdletBinding()]
    Param()

    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $url = "https://api.guerrillamail.com/ajax.php?f=get_email_address&ip=127.0.0.1&agent=Mozilla_foo_bar"
    try {
        Write-Verbose "Creating new session and requesting initial email address from $url"
        $resp = Invoke-WebRequest -Uri $url -Method Get -WebSession $session -ErrorAction Stop
        $email = ($resp.Content | ConvertFrom-Json)

        $guerrillaSession = [PSCustomObject]@{
            Session = $session
            Email = $email.email_addr
            EmailTimestamp = $email.email_timestamp
        }

        return $guerrillaSession
    }
    catch {
        Write-Error "Failed to create a new Guerrilla Mail session. The API may be unreachable or returned an error. `nOriginal Error: $($_.Exception.Message)"
        return $null
    }
}

function Get-MailAddress{
    # This function is now superseded by New-GuerrillaMailSession
    # It is kept for backward compatibility but will just create a new session.
    return New-GuerrillaMailSession
}

<#
.SYNOPSIS
    Sets or changes the temporary email address for the current session.

.DESCRIPTION
    This function allows you to set a custom email address using a specific username and domain.
    The new email address details are updated in the provided session object.

.PARAMETER GuerrillaSession
    The session object returned by New-GuerrillaMailSession. This is a mandatory parameter.

.PARAMETER user
    The username part of the email address you want to set. For example, 'my-test-user'.

.PARAMETER domain
    The domain part of the email address. Must be one of the allowed domains.

.EXAMPLE
    PS C:\> $session = New-GuerrillaMailSession
    PS C:\> Set-MailUser -GuerrillaSession $session -user "my-test-user" -domain "sharklasers.com"
    PS C:\> $session.Email
    my-test-user@sharklasers.com

.RETURNS
    The API response object on success. Returns $null on failure.
#>
function Set-MailUser{
    [CmdletBinding()]
    Param(
       [Parameter(Mandatory=$true)]
       [ValidateNotNull()]
       [PSCustomObject]$GuerrillaSession,
       [Parameter(Mandatory=$true)]
       [ValidateNotNullOrEmpty()]
       [string]$user,
       [Parameter(Mandatory=$true)]
       [ValidateSet("sharklasers.com","guerrillamail.com","guerrillamail.org","guerrillamail.net","grr.la")]
       [string]$domain
    ) #end param
    $url = "https://api.guerrillamail.com/ajax.php?f=set_email_user&email_user="+$user+"&domain="+$domain+"&lang=en&ip=127.0.0.1&agent=Mozilla_foo_bar"
    try {
        Write-Verbose "Setting email user to '$($user)@$($domain)' at $url"
        $resp = Invoke-WebRequest -Uri $url -Method Get -WebSession $GuerrillaSession.Session -ErrorAction Stop | ConvertFrom-Json
        $GuerrillaSession.Email = $resp.email_addr
        $GuerrillaSession.EmailTimestamp = $resp.email_timestamp
        return $resp
    }
    catch {
        Write-Error "Failed to set the email user. The API may be unreachable or returned an error. `nOriginal Error: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Checks the inbox for new emails.

.DESCRIPTION
    Retrieves a list of emails currently in the inbox for the session's email address.
    By default, it checks from the first email (sequence number 0).

.PARAMETER GuerrillaSession
    The session object returned by New-GuerrillaMailSession.

.PARAMETER seq_no
    The sequence ID of the oldest email to fetch. Defaults to 0.

.EXAMPLE
    PS C:\> $session = New-GuerrillaMailSession
    PS C:\> Start-Sleep -Seconds 5 # Wait for welcome email
    PS C:\> $inbox = Get-Mail -GuerrillaSession $session
    PS C:\> $inbox.list | Select-Object mail_id, mail_from, mail_subject

.RETURNS
    An object containing the list of emails and other inbox metadata. Returns $null on failure.
#>
function Get-Mail{
    [CmdletBinding()]
    Param(
       [Parameter(Mandatory=$true)]
       [ValidateNotNull()]
       [PSCustomObject]$GuerrillaSession,
       [Int]$seq_no = 0
    ) #end param
    $url_check = "https://api.guerrillamail.com/ajax.php?f=check_email&seq="+$seq_no+"&ip=127.0.0.1&agent=Mozilla_foo_bar"
    try {
        Write-Verbose "Checking for mail at $url_check"
        $obj_checkmail = Invoke-RestMethod $url_check -Method Get -WebSession $GuerrillaSession.Session -ErrorAction Stop
        return $obj_checkmail
    }
    catch {
        Write-Error "Failed to get mail. The API may be unreachable or returned an error. `nOriginal Error: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Fetches the full content of a specific email.

.DESCRIPTION
    Retrieves the complete body and details of a single email using its ID.

.PARAMETER GuerrillaSession
    The session object returned by New-GuerrillaMailSession.

.PARAMETER mail_id
    The ID of the email to fetch. This ID can be found from the output of Get-Mail.

.EXAMPLE
    PS C:\> $inbox = Get-Mail -GuerrillaSession $session
    PS C:\> $emailId = $inbox.list[0].mail_id
    PS C:\> $fullEmail = Get-MailContent -GuerrillaSession $session -mail_id $emailId
    PS C:\> $fullEmail.mail_body

.RETURNS
    An object containing the full details of the specified email. Returns $null on failure.
#>
function Get-MailContent{
    [CmdletBinding()]
    Param(
       [Parameter(Mandatory=$true)]
       [ValidateNotNull()]
       [PSCustomObject]$GuerrillaSession,
       [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
       [ValidateNotNullOrEmpty()]
       [string]$mail_id
    ) #end param
    $url_fetch = "https://api.guerrillamail.com/ajax.php?f=fetch_email&email_id="+$mail_id+"&ip=127.0.0.1&agent=Mozilla_foo_bar"
    try {
        Write-Verbose "Fetching content for mail_id '$($mail_id)' from $url_fetch"
        $obj_fetchmail = Invoke-RestMethod $url_fetch -Method Get -WebSession $GuerrillaSession.Session -ErrorAction Stop
        return $obj_fetchmail
    }
    catch {
        Write-Error "Failed to fetch mail content for mail_id '$($mail_id)'. The API may be unreachable or returned an error. `nOriginal Error: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Gets a list of emails from the inbox with an offset.

.DESCRIPTION
    Retrieves a list of emails from the inbox, allowing you to paginate through the list using an offset.

.PARAMETER GuerrillaSession
    The session object returned by New-GuerrillaMailSession.

.PARAMETER offset
    The number of emails to skip from the start of the inbox. Defaults to 0.

.PARAMETER seq_no
    The sequence ID to start from. Defaults to 0.

.EXAMPLE
    PS C:\> # Get the first 10 emails
    PS C:\> $firstPage = Get-MailList -GuerrillaSession $session -offset 0
    PS C:\> # Get the next 10 emails
    PS C:\> $secondPage = Get-MailList -GuerrillaSession $session -offset 10

.RETURNS
    An array of email objects. Returns $null on failure.
#>
function Get-MailList{
    [CmdletBinding()]
    Param(
       [Parameter(Mandatory=$true)]
       [ValidateNotNull()]
       [PSCustomObject]$GuerrillaSession,
       [Int]$offset = 0,
       [Int]$seq_no = 0
    ) #end param
    $url_check = "https://api.guerrillamail.com/ajax.php?f=get_email_list&seq="+$seq_no+"&offset="+$offset+"&ip=127.0.0.1&agent=Mozilla_foo_bar"
    try {
        Write-Verbose "Getting mail list with offset '$($offset)' from $url_check"
        $obj_checkmail = Invoke-RestMethod $url_check -Method Get -WebSession $GuerrillaSession.Session -ErrorAction Stop
        return $obj_checkmail.list
    }
    catch {
        Write-Error "Failed to get mail list. The API may be unreachable or returned an error. `nOriginal Error: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    A convenience function to set an email address and immediately check its inbox.

.DESCRIPTION
    This is a wrapper function that first calls Set-MailUser to set a specific email address and then
    immediately calls Get-Mail to retrieve the contents of its inbox.

.PARAMETER GuerrillaSession
    The session object returned by New-GuerrillaMailSession.

.PARAMETER user
    The username part of the email address you want to set.

.PARAMETER domain
    The domain part of the email address. Must be one of the allowed domains.

.EXAMPLE
    PS C:\> $session = New-GuerrillaMailSession
    PS C:\> $inbox = Get-MailFor -GuerrillaSession $session -user "my-test-user" -domain "guerrillamail.com"
    PS C:\> $inbox

.RETURNS
    An array of email objects found in the new inbox.
#>
function Get-MailFor{
    [CmdletBinding()]
    Param(
       [Parameter(Mandatory=$true)]
       [ValidateNotNull()]
       [PSCustomObject]$GuerrillaSession,
       [Parameter(Mandatory=$true)]
       [ValidateNotNullOrEmpty()]
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
