# PowerShell Guerrilla Mail Module

## Description

This PowerShell module provides a simple and effective way to interact with the [Guerrilla Mail API](https://www.guerrillamail.com/). Guerrilla Mail offers disposable, temporary email addresses to protect your privacy and avoid spam. This module allows you to programmatically create temporary email addresses, set custom usernames, and read received emails.

This module has been refactored to use modern, session-based authentication and includes robust error handling and documentation.

## Features

- Create a new temporary email address with a single command.
- Set a custom username and domain for your temporary address.
- Check the inbox and get a list of all emails.
- Fetch the full content of any email by its ID.
- Session-based interaction to handle API communication smoothly.
- Full comment-based help for all functions, accessible via `Get-Help`.

## Installation

1.  Ensure you have PowerShell installed on your system.
2.  Place the `tempmail.psm1` and `tempmail.psd1` files into a directory named `TempMail` within your PowerShell modules folder. Common locations are:
    -   Current user: `~\Documents\WindowsPowerShell\Modules\TempMail`
    -   All users: `C:\Program Files\WindowsPowerShell\Modules\TempMail`
3.  Open a new PowerShell terminal. The module should be auto-imported when you first use one of its commands. Alternatively, you can import it manually:
    ```powershell
    Import-Module TempMail
    ```

## Quick Start

Here is a simple example of how to use the module to get a new email address and read the first email that arrives.

```powershell
# 1. Import the module (if not already loaded)
Import-Module ./TempMail

# 2. Create a new session to get your temporary email address
Write-Host "Requesting a new temporary email address..."
$session = New-GuerrillaMailSession

if ($null -ne $session) {
    Write-Host "Success! Your new email is: $($session.Email)"

    # The first email is usually a "Welcome" email from Guerrilla Mail.
    # We'll wait a few seconds for it to arrive.
    Write-Host "Waiting 5 seconds for the welcome email to arrive..."
    Start-Sleep -Seconds 5

    # 3. Check your inbox
    Write-Host "Checking for new mail..."
    $inbox = Get-Mail -GuerrillaSession $session

    if ($inbox.list.Count -gt 0) {
        $firstEmail = $inbox.list[0]
        Write-Host "Found an email from '$($firstEmail.mail_from)' with subject: '$($firstEmail.mail_subject)'"

        # 4. Read the full email content
        Write-Host "Fetching full content of email ID: $($firstEmail.mail_id)"
        $fullEmail = Get-MailContent -GuerrillaSession $session -mail_id $firstEmail.mail_id

        Write-Host "--- Email Body ---"
        Write-Host $fullEmail.mail_body
        Write-Host "--------------------"
    } else {
        Write-Host "Inbox is empty."
    }
}
```
