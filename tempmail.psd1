@{

# Script module or binary module file associated with this manifest.
RootModule = 'tempmail.psm1'

# Version number of this module.
ModuleVersion = '1.1.0'

# A unique identifier for this module
GUID = 'e69d9536-52b8-4f23-9c87-84347206d3e8'

# Author of this module
Author = 'Jules'

# Company or vendor of this module
CompanyName = 'Unknown'

# Copyright statement for this module
Copyright = '(c) 2025 Jules. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A PowerShell module to interact with the Guerrilla Mail API for creating and reading temporary emails.'

# Functions to export from this module
FunctionsToExport = @(
    'New-GuerrillaMailSession',
    'Set-MailUser',
    'Get-Mail',
    'Get-MailContent',
    'Get-MailList',
    'Get-MailFor'
)

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = @()

}
