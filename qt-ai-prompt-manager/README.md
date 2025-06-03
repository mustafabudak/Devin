# Qt AI Prompt Manager

A Qt/QML application for managing AI prompts with advanced features for developers.

## Features

- **Prompt Simplification**: Automatically simplifies and professionalizes prompts for AI services
- **Compiler Error Processing**: Parses compiler errors and generates fix prompts for AI
- **Project Comparison**: Compares two project directories and generates analysis prompts
- **AI Integration**: Send prompts directly to OpenAI or Claude APIs
- **File Management**: Load/save prompts and error logs

## Building

Requirements:
- Qt 5.15 or later
- C++17 compiler

```bash
qmake qt-ai-prompt-manager.pro
make
```

## Usage

1. **Prompt Manager Tab**: 
   - Enter or load prompts
   - Simplify them for AI consumption
   - Send directly to AI services

2. **Compiler Errors Tab**:
   - Paste compiler output
   - Generate structured fix prompts

3. **Project Compare Tab**:
   - Select two project directories
   - Compare and generate analysis prompts

4. **AI Response Tab**:
   - View AI responses
   - Copy responses for further use

## API Keys

To use AI features, you'll need API keys from:
- OpenAI: https://platform.openai.com/api-keys
- Anthropic (Claude): https://console.anthropic.com/

## Supported Compiler Formats

- GCC/Clang error format
- MSVC error format
- Custom error parsing

## File Types Supported for Project Comparison

- C/C++: .cpp, .h
- QML/JavaScript: .qml, .js
- Python: .py
- Build files: .pro, .pri, CMakeLists.txt, Makefile
- Configuration: .json, .xml, .yaml
