---
external help file: PSTeedy-help.xml
Module Name: PSTeedy
online version:
schema: 2.0.0
---

# Connect-Teedy

## SYNOPSIS

Connect to a teedy instance using a username and password.

## SYNTAX

```PowerShell
Connect-Teedy [-Username] <String> [-Password] <String> [-URL] <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Connect to a teedy instance using a username and password.

## EXAMPLES

### Example 1

```powershell
PS C:\> Connect-Teedy -Username "Admin" -Password "Admin" -URL "https://demo.teedy.io"
```

The above example connects to a Teedy instance hosted at "https://demo.teedy.io" using the username and password of "Admin"

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password

The password for the user to access the Teedy instance.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -URL

The URL of the Teedy instance you would like to connect to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username

The username to access the Teedy instance with

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
