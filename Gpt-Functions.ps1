<#
.SYNOPSIS
    Invokes a conversation with the OpenAI API.
.PARAMETER message
    The message to send to the API.
.PARAMETER model
    The API model to use.
.EXAMPLE
    Invoke-Conversation "Hello, how are you?"
#>
function Invoke-Conversation {
   [CmdletBinding()]
   param (
       [Parameter(
         Mandatory=$true,
         ValueFromPipeline=$true,
         ValueFromPipelineByPropertyName=$true
       )]
       [string]$message,
       [string]$model = 'gpt-3.5-turbo'
   )

   # Check if the session variable "ConversationHistory" exists, and create it if it doesn't
   if (-not (Test-Path $global:ConversationHistory)) {
       $Global:ConversationHistory = @(
         @{
           role = 'system'
           content = $Global:GptSystemMessage
         }
       )
   }

   # Add the current message to the conversation history with the specified role
   $currentMessage = @{
       role = 'user'
       content = $message
   }

   $Global:ConversationHistory += $currentMessage

   # Construct the request body with the conversation history
   $body = @{
       model = $model
       messages = $Global:ConversationHistory
   }

   $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" -Method Post -Headers @{
       Authorization="Bearer $env:OPENAI_API_KEY"
     } -Body (ConvertTo-Json $body) -ContentType "application/json"

   $content = $response.choices[0].message.content.Trim()

   # Add the AI response to the conversation history with the "assistant" role
   $aiResponse = @{
       role = "assistant"
       content = $content
   }

   $Global:ConversationHistory += $aiResponse

   # Return the AI response text
   Write-Output $content
}

<#
.SYNOPSIS
    Resets the conversation history for the current session.
#>
function Reset-Conversation {
   $Global:ConversationHistory = @(
       @{
           role = 'system'
           content = $Global:GptSystemMessage
       }
   )
}

<#
.SYNOPSIS
    Writes the conversation history to a file.
.PARAMETER ConversationName
    The name of the conversation (will be used as the name of the file).
.PARAMETER Directory
    The directory to save the conversation file. If not specified, the file will be saved in the default directory.
.EXAMPLE
    Write-Conversation -ConversationName mt_everest_height -Directory C:\Conversations
#>
function Write-Conversation {
   [CmdletBinding()]
   param (
       [string]$ConversationName,
       [string]$Directory
   )

   if (-not($ConversationName)) {
       $ConversationName = Invoke-Conversation "In 4 words or fewer, summarize this conversation. Use underscores for spaces. Example: mt_everest_height, ai_completion_script, dinner_ideas_for_datenight"
       $ConversationName = $ConversationName -replace " ","_" -replace "\.",""
   }

   if (-not($Directory)) {
       $DefaultDirectory = "$HOME\conversations"
   } else {
       $DefaultDirectory = $Directory
   }

   if (-not(Test-Path $DefaultDirectory)) {
       New-Item $DefaultDirectory -Type Directory
   }

   if (Test-Path "$DefaultDirectory\$ConversationName") {
       Write-Host "$DefaultDirectory\$ConversationName already exists. (R)ename, (O)verwrite, (A)bort:\n"
       $Selection = Read-Host "Enter Selection"

       while ($Selection.ToLower() -notin ("r", "o", "a")) {
           $Selection = Read-Host "Enter Selection"
       }

       if ($Selection.ToLower() -eq "r") {
           $ConversationName = Read-Host "Enter new Conversation Name: "
           if (Test-Path "$DefaultDirectory\$ConversationName") {
               Write-Host "$DefaultDirectory\$ConversationName already exists. (R)ename, (O)verwrite, (A)bort:\n"
           }
       } elseif ($Selection.ToLower() -eq "a") {
           return
       }
   }

   $filename = "$DefaultDirectory\$ConversationName.json"
   Write-Host "Writing conversation to $filename."

   try {
       $global:ConversationHistory | ConvertTo-Json | Out-File $filename -ErrorAction Stop
       Write-Output "Conversation written successfully."
   } catch {
       Write-Error "Failed to write conversation to $filename`: $_"
   }
}

<#
.SYNOPSIS
    Sets the conversation history for the current session using a conversation file.
.PARAMETER filename
    The name of the conversation file.
.EXAMPLE
    Set-Conversation C:\Conversations\mt_everest_height.json
#>
function Set-Conversation {
   [CmdletBinding()]
   param (
       [Parameter(
         Mandatory=$true,
         ValueFromPipeline=$true,
         ValueFromPipelineByPropertyName=$true
       )]
       [string]$filename
   )

   try {
       $json = Get-Content $filename -Raw -ErrorAction Stop

       $Global:ConversationHistory = $json | ConvertFrom-Json
       Write-Output "Conversation loaded successfully."
   } catch {
       Write-Error "Failed to load conversation: $_"
   }
}

Set-Alias -Name gpt -Value Invoke-Conversation
Set-Alias -Name rgpt -Value Reset-Conversation
Set-Alias -Name wgpt -Value Write-Conversation
Set-Alias -Name lgpt -Value Load-Conversation
