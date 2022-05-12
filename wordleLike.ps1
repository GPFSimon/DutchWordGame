<###############################################################################
################################################################################
##                          Dutch WordleLikle                                 ##
## Author: Simon Howlett	Date:  05/10/2022   DateLastModified: 05/12/2022  ##
## Purpose: Game to remember Dutch Words and remember PowerShell Code         ##
## Synatx: Fun Word Game                                                      ##
################################################################################
###############################################################################>

$DictionaryFile = "$PSScriptRoot\src\dictionary.csv"
$Answered = 0
$guessFullCount = 0

function main {
    
    #Set window colors and title
    $Host.UI.RawUI.WindowTitle = “Dutch Wordle-Like"
    $Host.UI.RawUI.BackgroundColor = “Black” 
    $Host.UI.RawUI.ForegroundColor = “Green”
    
    
    clear-host
    #Direct to MenuHelper Function
    MenuHelper
} #End of Func main

#MenuHelper fuction, to display menu options
function MenuHelper([string]$title,[array]$MenuItems){
    $title = "║`t Dutch Wordle-Like `t"
    $MenuItems = @("║`t1. Play The Game!`t",`
                   "`n║`t2. Learn the Rules!`t",`
                   "`n║`t3. To Exit the Program`t")
    $randomArray = @("`n╚","══════════════════════════════","╝") -join ''

#Creating menu box    
$box = @"
╔══════════════════════════════╗
$title
╠══════════════════════════════╣
$MenuItems$randomArray 
"@
    $box
    $MenuItems = read-host "Please make a selection [1-3]"
    
#Redirect to a function depending on selection
        Switch($MenuItems){
            1{Play}
            2{Learn}
            3{exit}
            }
}#End of Func MenuHelper

Function Play {

    $correct = $false
    $word = New-DutchWord
    $guessCount = 0

    Do {

        write-host "What is the dutch word for " -NoNewline; Write-Host -ForegroundColor Red $word.English -NoNewline; Write-Host " ?"

        $guess = read-host
        If ($guess -eq 2) {write-host "The answer was " -NoNewline; Write-Host $word.Dutch -ForegroundColor Yellow; Play}
        If ($guess -eq 3) {write-host "You answered: $Answered word(s) within $guessFullCount tries"; exit}

        $correct = GuessCheck $word.Dutch $guess
        $guessCount++
        $guessFullCount++
        } while ($correct -eq $false)
        $Answered++
        If ($guessCount -eq 1) { write-host "Congrats, correct within $guessCount try!"; Play }
            else {write-host "Congrats, correct within $guessCount tries!"; Play}
        
} #End of Play

Function Learn {
    write-host "This is where you learn about how the game works and stuff. Cool eh?`n"
    write-host -ForegroundColor Green "GREEN" -NoNewline; Write-Host " means that the letter is in the final answer"
    write-host -ForegroundColor Yellow "YELLOW" -NoNewline; Write-Host " means that the letter is in the final answer but a different spot"
    write-host -ForegroundColor Gray "GRAY" -NoNewline; Write-Host " means that the letter is not in the final answer"
    write-host "Type 2 to " -NoNewline; write-host -ForegroundColor Red "skip" -NoNewline; Write-Host " the word!"
    write-host "Type 3 to " -NoNewline; write-host -ForegroundColor Red "exit" -NoNewline; Write-Host " the game!"
    write-host ""
    Play
} #End of Learn

Function New-DutchWord {
    $csvDict = Import-Csv -Path $DictionaryFile 
    $word = Get-Random $csvDict
 Return($word)
}

Function GuessCheck($w,$g) {

    [array]$changechars =@()
    [int]$count = -1
    $guessNew = New-Object System.Collections.ArrayList($null)

If ($w -ne $g) {
    
    0..($w.length-1) | ForEach-Object {
            $count++
            #Check for letters in correct spots
            if ($g[$_] -eq $w[$_]) {
                write-host -ForegroundColor Green $g.ToUpper()[$_] -NoNewline
                # write-host "guess letter:" $g[$_] "and" "word letter:" $w[$_]
                $changechars += $count
            }
            elseif($w.ToCharArray() -contains $g[$_]) {
                write-host -ForegroundColor Yellow $g.ToUpper()[$_] -NoNewline
            }
            else { write-host -ForegroundColor Gray $g.ToUpper()[$_] -NoNewline}
        }
    $count = -1
    #Check guessed letters
    
        $g.ToCharArray() | ForEach-Object {
            $count++
            #If char index is in the right place
            if ($count -in $changechars) {
                    $null = $guessNew.Add("$_")
                }
                #If not in right place, replace
                Else {
                    $null = $guessNew.Add("*")
                    }
            }
            
            while ($guessNew.Count -ne $w.Length) {
                If ($guessNew.Count -gt $w.Length) { 
                    #write-host "Guess Length:" $guessNew.Count "Word length:" $w.length
                    $null = $guessNew.RemoveAt($guessNew.Count-1)
                    }
                    else {$null = $guessNew.Add("*")}
            }
          
    $guessNew = $guessNew -join ''
    write-host ""
    write-host "Try Again: " $guessNew.ToUpper() "("$w.length")"
    Return ($false)
}
Else {
    
    Return ($true)
}
}
main