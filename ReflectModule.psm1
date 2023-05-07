function Add-QuestionAndAnswer {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Question
    )

    $output = "Question: A" + $Question + "`nAnswer: Let's work this out in a step by step way to be sure we have the right answer"
    return $output
}

function Invoke-ReflectGPT {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Question
    )
    $Question = Add-QuestionAndAnswer $Question

    $Responses = @()

    # Ask GPT-4 the query three times
    foreach ($i in 0..2) {
        Reset-Conversation
        $response = Invoke-Conversation -message $Question -temperature 0.6 -model gpt-4 
        Write-Host $Response
        $Responses[$i] = $Response
      }

  }
