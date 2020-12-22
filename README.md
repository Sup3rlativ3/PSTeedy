# PSTeedy

Powershell Module for interfacing with Teedy from Teedy.io

## Overview

PSTeedy is a PowerShell module for interfacing with a Teedy instance. You can create or remove folders, files and tags.

| :exclamation:  Important   |
|-----------------------------------------|
| This module is under heavy development. For a stable script, use [this](https://github.com/paradizelost/Powershell-Public/blob/master/teedy.ps1) |

## Installation

Download the repository and copy to your PowerShell modules path

```PowerShell
C:\User\Documents\WindowsPowerShell\Modules
```

You can install PSTeedy from the PowerShell gallery using the below command.

```PowerShell
PS C:\> Install-Module PSTeedy -Scope Currentuser
```

## Examples

```PowerShell
PS C:\> Connect-Teedy -Username "Admin" -Password "Admin" -URL "https://demo.teedy.io"
```

The above example connects to a Teedy instance hosted at "https://demo.teedy.io" using the username and password of "Admin"

```PowerShell
PS C:\> New-TeedyDirectory -Directory "C:\Docs\" -AnchorTag "Upload Test" -Tags "Expenses", "Internal" -ExtractMsgFiles
```

The above example will mimic the directory structure under "C:\Docs" and extract attachments from .msg files.
