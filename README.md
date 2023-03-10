# OpenAI API Conversation Script

This PowerShell script enables you to have a conversation with the OpenAI API. You can input a message to send to the API and the script will return an AI response.

## Usage

The following functions are available:

- **Invoke-Conversation**: Invokes a conversation with the OpenAI API. Accepts a message to send to the API and an optional model name as parameters.
- **Reset-Conversation**: Resets the conversation history for the current session.
- **Write-Conversation**: Writes the conversation history to a file. Accepts a conversation name and optional directory as parameters.
- **Import-Conversation**: Sets the conversation history for the current session using a conversation file. Accepts a file name as a parameter.

To use this script, you'll need an API key. Set your API key using the following environment variable:

```powershell
$env:OPENAI_API_KEY="your_api_key_here"
```

You can then call the desired function using the following syntax:

```powershell
Invoke-Conversation -message "Hello, how are you?"
```

## Examples

To start a conversation with the default model:

```powershell
Invoke-Conversation -message "Hello, how are you?"
```

To start a conversation with a specific model:

```powershell
Invoke-Conversation -message "Hello, how are you?" -model "gpt-3.5-turbo-0301"
```

To reset the conversation history:

```powershell
Reset-Conversation
```

To write the conversation history to a file:

```powershell
Write-Conversation -ConversationName "my_conversation" -Directory "C:\Conversations"
```

To import a conversation file:

```powershell
Import-Conversation -filename "C:\Conversations\my_conversation.json"
```