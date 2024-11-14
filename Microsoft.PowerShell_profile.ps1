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

