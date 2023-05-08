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
        [string]$Question,
        [int32]$iterations = 3
    )

    $optimizedQuestion = Add-QuestionAndAnswer -Question $Question

    $Responses = @()

    # Ask GPT-4 the query three times
    foreach ($i in 0..$iterations-1) {
        Reset-Conversation
        $response = Invoke-Conversation -message $optimizedQuestion -temperature 0.6 -model gpt-4 
        $Responses += $Response
      }

    $ReasearchPrompt = "You are a researcher tasked with investigating the $iterations response options provided. List the flaws and faulty logic of each answer option. Let's work this out in a step by step way to be sure we have all the errors. The question was, '$Question'. The responses were: "
    $j = 0 
   
   foreach ($response in $Responses) {
      $ReasearchPrompt += "$j`: $response `n"
      $j++
    }
    
    Reset-Conversation

    $researchResponse = Invoke-Conversation -message $ReasearchPrompt -temperature 0.6 -model gpt-4 

    Write-Output $researchResponse

    $ResolverPrompt = "$ReasearchPrompt`n$researchResponse`n  You are a resolver tasked with 1: finding which of the $iterations answer options the researcher thought was best. 2: Improving that answer, and 3: Printing the inproved answer in full. Let's work this out in a step by step manner to be sure we have the right answer: `n"

    $ResolverAnswer = Invoke-Conversation -message $ResolverPrompt -temperature .03 -model gpt-4

    Write-Output $ResolverAnswer


  }
