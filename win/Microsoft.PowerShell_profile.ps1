#
# PS> New-Item -path $profile -type file -force
#

function prompt() {
  $dirSep = [IO.Path]::DirectorySeparatorChar
  $pathComponents = $PWD.Path.Split($dirSep)
  $displayPath = if ($pathComponents.Count -le 3) {
    $PWD.Path
  } else {
    '{1}{0}…{0}{2}' -f $dirSep, ($pathComponents[0]), ($pathComponents[-2,-1] -join $dirSep)
  }
  $displayPath + ">"
  # "PS {0}$('>' * ($nestedPromptLevel + 1)) " -f $displayPath
}
set-psreadlineoption -Colors @{ InlinePrediction = $PSStyle.Foreground.BrightBlack }

# --- Text search and replace helpers ---

function Get-SearchableFile {
    <#
    .SYNOPSIS
        Enumerates candidate text files under a path while excluding directories and binary files.
    .DESCRIPTION
        Recursively collects files under Path, skips any file inside ExcludeDirs, and filters
        out files containing a NUL byte (0x00) in their leading bytes or unreadable files.
    .PARAMETER Path
        Root directory or file path to enumerate. Defaults to the current directory ('.').
    .PARAMETER Extensions
        Optional file inclusion filters (e.g., '*.ts', '*.md'). Returns all matching files when omitted.
    .PARAMETER ExcludeDirs
        Directory names to exclude from enumeration.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = '.',

        [Parameter()]
        [string[]]$Extensions,

        [Parameter()]
        [string[]]$ExcludeDirs = @('.git', 'node_modules', 'dist', 'build', '.svelte-kit', 'out', 'target')
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Warning "Path not found: $Path"
        return
    }

    # Build a regex matching path separators around excluded directory names
    $escapedDirs = ($ExcludeDirs | ForEach-Object { [regex]::Escape($_) }) -join '|'
    $excludeRegex = "[/\\]($escapedDirs)[/\\]"

    $gciParams = @{
        Path    = $Path
        Recurse = $true
        File    = $true
    }
    if ($Extensions -and $Extensions.Count -gt 0) {
        $gciParams['Include'] = $Extensions
    }

    Get-ChildItem @gciParams | Where-Object {
        # Skip files inside excluded directories
        if ($_.FullName -match $excludeRegex) { return $false }

        # Treat files with a NUL byte in the first 1024 bytes as binary
        try {
            $stream = [System.IO.File]::OpenRead($_.FullName)
            try {
                $buffer = New-Object byte[] 1024
                $read = $stream.Read($buffer, 0, $buffer.Length)
                for ($i = 0; $i -lt $read; $i++) {
                    if ($buffer[$i] -eq 0) { return $false }
                }
            }
            finally {
                $stream.Dispose()
            }
        }
        catch {
            Write-Warning "Skipping unreadable file: $($_.FullName)"
            return $false
        }

        return $true
    }
}

function Search-Text {
    <#
    .SYNOPSIS
        Searches text files recursively while skipping excluded directories and binary files.
    .DESCRIPTION
        Uses Get-SearchableFile to collect candidate files and runs Select-String against them.
    .PARAMETER Pattern
        The search pattern passed to Select-String.
    .PARAMETER Path
        Root directory or file path to search. Defaults to the current directory ('.').
    .PARAMETER Extensions
        Optional file inclusion filters (e.g., '*.ts', '*.md').
    .PARAMETER ExcludeDirs
        Directory names to exclude from search results.
    .PARAMETER Context
        Number of leading and trailing lines to display around each match.
    .PARAMETER CaseSensitive
        Performs a case-sensitive match when specified.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern,

        [Parameter(Position = 1)]
        [string]$Path = '.',

        [Parameter()]
        [string[]]$Extensions,

        [Parameter()]
        [string[]]$ExcludeDirs = @('.git', 'node_modules', 'dist', 'build', '.svelte-kit', 'out', 'target'),

        [Parameter()]
        [int]$Context = 0,

        [Parameter()]
        [switch]$CaseSensitive
    )

    Get-SearchableFile -Path $Path -Extensions $Extensions -ExcludeDirs $ExcludeDirs |
        Select-String -Pattern $Pattern -Context $Context -CaseSensitive:$CaseSensitive
}

function Replace-Text {
    <#
    .SYNOPSIS
        Searches text files recursively and replaces matching text while skipping
        excluded directories and binary files.
    .DESCRIPTION
        Uses Get-SearchableFile to collect candidate files and replaces matching text.
        Supports -WhatIf and -Confirm via ShouldProcess.
    .PARAMETER Pattern
        The search pattern (regular expression by default, or literal string with -SimpleMatch).
    .PARAMETER Replacement
        The replacement string.
    .PARAMETER Path
        Root directory or file path to search. Defaults to the current directory ('.').
    .PARAMETER Extensions
        Optional file inclusion filters (e.g., '*.ts', '*.md').
    .PARAMETER ExcludeDirs
        Directory names to exclude from search and replacement.
    .PARAMETER SimpleMatch
        Treats Pattern as a literal string instead of a regular expression.
    .PARAMETER CaseSensitive
        Performs a case-sensitive match when specified.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Replacement,

        [Parameter(Position = 2)]
        [string]$Path = '.',

        [Parameter()]
        [string[]]$Extensions,

        [Parameter()]
        [string[]]$ExcludeDirs = @('.git', 'node_modules', 'dist', 'build', '.svelte-kit', 'out', 'target'),

        [Parameter()]
        [switch]$SimpleMatch,

        [Parameter()]
        [switch]$CaseSensitive
    )

    $regexPattern = if ($SimpleMatch) { [regex]::Escape($Pattern) } else { $Pattern }
    $regexOptions = [System.Text.RegularExpressions.RegexOptions]::Multiline
    if (-not $CaseSensitive) {
        $regexOptions = $regexOptions -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    }
    $regex = [System.Text.RegularExpressions.Regex]::new($regexPattern, $regexOptions)

    Get-SearchableFile -Path $Path -Extensions $Extensions -ExcludeDirs $ExcludeDirs | ForEach-Object {
        $filePath = $_.FullName

        # Read with UTF-8 while preserving BOM if present
        $utf8WithBom = New-Object System.Text.UTF8Encoding($true)
        $content = [System.IO.File]::ReadAllText($filePath, $utf8WithBom)

        $matchCount = $regex.Matches($content).Count
        if ($matchCount -eq 0) {
            return
        }

        $updatedContent = $regex.Replace($content, $Replacement)
        if ($updatedContent -eq $content) {
            return
        }

        if ($PSCmdlet.ShouldProcess($filePath, "Replace $matchCount occurrence(s) of '$Pattern'")) {
            [System.IO.File]::WriteAllText($filePath, $updatedContent, $utf8WithBom)
            [PSCustomObject]@{
                Path         = $filePath
                Replacements = $matchCount
            }
        }
    }
}

# Optional alias for quick interactive search
Set-Alias -Name fg -Value Search-Text
